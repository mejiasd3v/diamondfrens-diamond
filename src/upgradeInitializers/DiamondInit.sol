// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import { IERC173 } from "../interfaces/IERC173.sol";
import { IERC165 } from "../interfaces/IERC165.sol";
import { AppStorage } from "../libraries/LibAppStorage.sol";

/// @title DiamondInit
/// @author Modified from Nick Mudge: https://github.com/mudgen/diamond-3-hardhat
/// @notice Initialize variables inside the diamond
/// @dev Utilizes 'LibDiamond', 'IDiamondCut', 'IDiamondLoupe', 'IERC165' and 'IERC173'
contract DiamondInit {
    AppStorage internal s;

    struct Args {
        address protocolFeeDestination;
        address protocolFeeDestination2;
    }

    /////////////
    /// LOGIC ///
    /////////////

    /// @notice Initialize diamond
    function init(Args memory args) external virtual {
        /// @notice Add ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // add your own state variables
        // EIP-2535 specifies that the `diamondCut` function takes two optional
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface

        s.protocolFeeDestination = args.protocolFeeDestination;
        s.protocolFeeDestination2 = args.protocolFeeDestination2;

        s.subjectFeePercent = 7 ether / 100;
        s.protocolFeePercent = 2 ether / 100;
        s.referralFeePercent = 1 ether / 100;
        s.initialPrice = 1 ether / 250;
    }
}
