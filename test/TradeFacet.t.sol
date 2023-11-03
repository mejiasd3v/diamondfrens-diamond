// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.21;

import "./utils/DiamondTest.sol";

contract TradeFacetTest is DiamondTest {
    TradeFacet tradeFacet;
    address user = makeAddr("user");
    address sharesSubject = makeAddr("sharesSubject");

    function setUp() public {
        vm.startPrank(diamondOwner);
        DiamondFrens diamond = createDiamond();
        tradeFacet = TradeFacet(address(diamond));
        vm.stopPrank();

        vm.deal(user, 1_000_000 ether);
    }

    function test_buyShares_UserCanBuyShares(uint256 sharesAmount) public {
        vm.assume(sharesAmount > 0);
        vm.assume(sharesAmount < 100);

        uint256 initialBalance = address(tradeFacet).balance;
        uint256 price = tradeFacet.getBuyPriceAfterFee(sharesSubject, sharesAmount);
        console.log("price", price);
        vm.prank(user);
        tradeFacet.buyShares{ value: price }(sharesSubject, sharesAmount);

        uint256 finalBalance = address(tradeFacet).balance;
        assertTrue(finalBalance > initialBalance, "Balance did not increase after buying shares");

        uint256 shares = tradeFacet.sharesBalanceOf(sharesSubject, user);
        assertTrue(shares > 0, "No shares were bought");
    }
}
