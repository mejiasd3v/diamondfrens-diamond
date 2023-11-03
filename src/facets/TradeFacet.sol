// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AppStorage, DEFAULT_WEIGHT_A, DEFAULT_WEIGHT_B, DEFAULT_WEIGHT_C } from "../libraries/LibAppStorage.sol";
import { LibPausable } from "../libraries/LibPausable.sol";

import "forge-std/console.sol";

contract TradeFacet {
    AppStorage internal s;

    event Trade(
        address indexed buyer,
        address indexed sharesSubject,
        bool indexed isBuy,
        uint256 amount,
        uint256 price,
        uint256 protocolFee,
        uint256 subjectFee,
        uint256 referralFee,
        uint256 totalShares,
        uint256 nextPrice,
        uint256 myShares
    );
    event ReferralSet(address indexed user, address indexed referrer);

    error InvalidAmount();
    error InsufficientPayment();
    error TransferFailed();
    error InsufficientShares();

    function getPrice(uint256 supply, uint256 amount) public view returns (uint256) {
        uint256 adjustedSupply = supply + DEFAULT_WEIGHT_C;
        uint256 baseValue = adjustedSupply - 1;
        uint256 baseValuePlusAmount = baseValue + amount;

        uint256 sumBase = baseValue * adjustedSupply * (2 * baseValue + 1) / 6;
        uint256 sumBasePlusAmount = baseValuePlusAmount * (adjustedSupply + amount) * (2 * baseValuePlusAmount + 1) / 6;

        uint256 weightedDifference = DEFAULT_WEIGHT_A * (sumBasePlusAmount - sumBase);
        uint256 price = DEFAULT_WEIGHT_B * weightedDifference * s.initialPrice / 1 ether / 1 ether;

        return price < s.initialPrice ? s.initialPrice : price;
    }

    function sharesBalanceOf(address sharesSubject, address user) public view returns (uint256) {
        return s.sharesBalanceOf[sharesSubject][user];
    }

    function getBuyPrice(address sharesSubject, uint256 amount) public view returns (uint256) {
        return getPrice(s.sharesSupplyOf[sharesSubject], amount);
    }

    function getSellPrice(address sharesSubject, uint256 amount) public view returns (uint256) {
        if (s.sharesSupplyOf[sharesSubject] == 0) {
            return 0;
        }
        if (amount == 0) {
            return 0;
        }
        if (s.sharesSupplyOf[sharesSubject] < amount) {
            return 0;
        }
        return getPrice(s.sharesSupplyOf[sharesSubject] - amount, amount);
    }

    function getBuyPriceAfterFee(address sharesSubject, uint256 amount) public view returns (uint256) {
        uint256 price = getBuyPrice(sharesSubject, amount);
        uint256 protocolFee = price * s.protocolFeePercent / 1 ether;
        uint256 subjectFee = price * s.subjectFeePercent / 1 ether;
        uint256 referralFee = price * s.referralFeePercent / 1 ether;
        return price + protocolFee + subjectFee + referralFee;
    }

    function getSellPriceAfterFee(address sharesSubject, uint256 amount) public view returns (uint256) {
        uint256 price = getSellPrice(sharesSubject, amount);
        uint256 protocolFee = price * s.protocolFeePercent / 1 ether;
        uint256 subjectFee = price * s.subjectFeePercent / 1 ether;
        uint256 referralFee = price * s.referralFeePercent / 1 ether;
        return price - protocolFee - subjectFee - referralFee;
    }

    // Core Logic

    function buyShares(address sharesSubject, uint256 amount) public payable {
        // Ensure the contract is not paused and the amount is greater than 0
        LibPausable.enforceIsUnpaused(s);
        if (amount == 0) {
            revert InvalidAmount();
        }

        // Calculate the supply and price
        uint256 supply = s.sharesSupplyOf[sharesSubject];
        uint256 price = getPrice(supply, amount);

        // Increase the total value locked
        s.tvlOf[sharesSubject] += price;

        // Calculate the fees
        uint256 protocolFee = price * s.protocolFeePercent / 1 ether;
        uint256 subjectFee = price * s.subjectFeePercent / 1 ether;
        uint256 referralFee = price * s.referralFeePercent / 1 ether;

        // Ensure the payment is sufficient
        if (msg.value < price + protocolFee + subjectFee + referralFee) {
            revert InsufficientPayment();
        }

        // Update the shares balance and supply
        s.sharesBalanceOf[sharesSubject][msg.sender] = s.sharesBalanceOf[sharesSubject][msg.sender] + amount;
        s.sharesSupplyOf[sharesSubject] = supply + amount;

        // Calculate the next price and the shares of the sender
        uint256 nextPrice = getPrice(s.sharesSupplyOf[sharesSubject], 1);
        uint256 myShares = s.sharesBalanceOf[sharesSubject][msg.sender];
        uint256 totalShares = supply + amount;

        // Send the protocol and subject fees
        _sendToProtocol(protocolFee);
        _sendToSubject(sharesSubject, subjectFee);

        // Calculate the refund amount
        uint256 refundAmount = msg.value - (price + protocolFee + subjectFee + referralFee);

        // If there is a refund amount, send it to the sender
        if (refundAmount > 0) {
            console.log("refundAmount", refundAmount);
            _sendToSubject(msg.sender, refundAmount);
        }

        // If there is a referral fee, send it to the referrer
        if (referralFee > 0) {
            console.log("referralFee", referralFee);
            _sendToReferrer(msg.sender, referralFee);
        }

        // Emit a trade event
        emit Trade(
            msg.sender,
            sharesSubject,
            true,
            amount,
            price,
            protocolFee,
            subjectFee,
            referralFee,
            totalShares,
            nextPrice,
            myShares
        );
    }

    function sellShares(address sharesSubject, uint256 amount) public payable {
        LibPausable.enforceIsUnpaused(s);
        if (amount == 0) {
            revert InvalidAmount();
        }

        uint256 supply = s.sharesSupplyOf[sharesSubject];
        uint256 price = getPrice(supply - amount, amount);
        s.tvlOf[sharesSubject] -= price;

        uint256 protocolFee = price * s.protocolFeePercent / 1 ether;
        uint256 subjectFee = price * s.subjectFeePercent / 1 ether;
        uint256 referralFee = price * s.referralFeePercent / 1 ether;

        if (s.sharesBalanceOf[sharesSubject][msg.sender] < amount) {
            revert InsufficientShares();
        }

        s.sharesBalanceOf[sharesSubject][msg.sender] = s.sharesBalanceOf[sharesSubject][msg.sender] - amount;
        s.sharesSupplyOf[sharesSubject] = supply - amount;
        uint256 nextPrice = getPrice(s.sharesSupplyOf[sharesSubject], 1);
        uint256 myShares = s.sharesBalanceOf[sharesSubject][msg.sender];
        uint256 totalShares = supply - amount;

        _sendToSubject(msg.sender, price - protocolFee - subjectFee - referralFee);
        _sendToProtocol(protocolFee);
        _sendToSubject(sharesSubject, subjectFee);

        if (referralFee > 0) {
            _sendToReferrer(msg.sender, referralFee);
        }

        emit Trade(
            msg.sender,
            sharesSubject,
            false,
            amount,
            price,
            protocolFee,
            subjectFee,
            referralFee,
            totalShares,
            nextPrice,
            myShares
        );
    }

    // Internal

    function _sendToSubject(address sharesSubject, uint256 subjectFee) internal {
        (bool success,) = sharesSubject.call{ value: subjectFee }("");
        if (!success) {
            revert TransferFailed();
        }
    }

    function _sendToProtocol(uint256 protocolFee) internal {
        uint256 fee2 = protocolFee * 3 / 10;
        uint256 fee = protocolFee - fee2;
        (bool success,) = s.protocolFeeDestination.call{ value: fee }("");
        if (!success) {
            revert TransferFailed();
        }
        (bool success2,) = s.protocolFeeDestination2.call{ value: fee2 }("");
        if (!success2) {
            revert TransferFailed();
        }
    }

    function _sendToReferrer(address sender, uint256 referralFee) internal {
        address referrer = s.userToReferrer[sender];
        if (referrer != address(0) && referrer != sender) {
            (bool success,) = referrer.call{ value: referralFee, gas: 30_000 }("");
            if (!success) {
                _sendToProtocol(referralFee);
            }
        } else {
            _sendToProtocol(referralFee);
        }
    }

    function _setReferrer(address user, address referrer) internal {
        if (s.userToReferrer[user] == address(0) && user != referrer) {
            s.userToReferrer[user] = referrer;
            emit ReferralSet(user, referrer);
        }
    }
}
