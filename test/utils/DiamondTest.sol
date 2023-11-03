// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.21;

import "forge-std/Test.sol";
import { IDiamondCut } from "src/interfaces/IDiamondCut.sol";
import { DiamondFrens } from "src/DiamondFrens.sol";
import { DiamondCutFacet } from "src/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "src/facets/DiamondLoupeFacet.sol";
import { OwnershipFacet } from "src/facets/OwnershipFacet.sol";
import { AuthorizationFacet } from "src/facets/AuthorizationFacet.sol";
import { DiamondInit } from "src/upgradeInitializers/DiamondInit.sol";
import { PausationFacet } from "src/facets/PausationFacet.sol";
import { TradeFacet } from "src/facets/TradeFacet.sol";
import { ContentFacet } from "src/facets/ContentFacet.sol";

contract DiamondTest is Test {
    address internal diamondOwner = makeAddr("diamondOwner");
    address internal protocolFeeDestination = makeAddr("protocolFeeDestination");
    address internal protocolFeeDestination2 = makeAddr("protocolFeeDestination2");
    IDiamondCut.FacetCut[] internal cut;

    function createDiamond() internal returns (DiamondFrens) {
        DiamondCutFacet diamondCut = new DiamondCutFacet();
        DiamondFrens diamond = new DiamondFrens(
            diamondOwner,
            address(diamondCut)
        );
        DiamondInit diamondInit = new DiamondInit();

        setDiamondLoupeFacet();
        setOwnershipFacet();
        setAuthorizationFacet();
        setPausationFacet();
        setTradeFacet();
        setContentFacet();

        DiamondInit.Args memory initArgs;
        initArgs.protocolFeeDestination = protocolFeeDestination;
        initArgs.protocolFeeDestination2 = protocolFeeDestination2;

        bytes memory data = abi.encodeWithSelector(DiamondInit.init.selector, initArgs);
        DiamondCutFacet(address(diamond)).diamondCut(cut, address(diamondInit), data);

        delete cut;

        return diamond;
    }

    function setDiamondLoupeFacet() private {
        DiamondLoupeFacet diamondLoupe = new DiamondLoupeFacet();
        bytes4[] memory functionSelectors;
        functionSelectors = new bytes4[](5);
        functionSelectors[0] = DiamondLoupeFacet.facetFunctionSelectors.selector;
        functionSelectors[1] = DiamondLoupeFacet.facets.selector;
        functionSelectors[2] = DiamondLoupeFacet.facetAddress.selector;
        functionSelectors[3] = DiamondLoupeFacet.facetAddresses.selector;
        functionSelectors[4] = DiamondLoupeFacet.supportsInterface.selector;
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(diamondLoupe),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: functionSelectors
            })
        );
    }

    function setOwnershipFacet() private {
        OwnershipFacet ownership = new OwnershipFacet();
        bytes4[] memory functionSelectors;
        functionSelectors = new bytes4[](2);
        functionSelectors[0] = OwnershipFacet.owner.selector;
        functionSelectors[1] = OwnershipFacet.transferOwnership.selector;
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(ownership),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: functionSelectors
            })
        );
    }

    function setAuthorizationFacet() private {
        AuthorizationFacet authorization = new AuthorizationFacet();
        bytes4[] memory functionSelectors;
        functionSelectors = new bytes4[](3);
        functionSelectors[0] = AuthorizationFacet.authorized.selector;
        functionSelectors[1] = AuthorizationFacet.authorize.selector;
        functionSelectors[2] = AuthorizationFacet.unAuthorize.selector;
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(authorization),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: functionSelectors
            })
        );
    }

    function setPausationFacet() private {
        PausationFacet facet = new PausationFacet();
        bytes4[] memory functionSelectors;
        functionSelectors = new bytes4[](3);
        functionSelectors[0] = PausationFacet.paused.selector;
        functionSelectors[1] = PausationFacet.pause.selector;
        functionSelectors[2] = PausationFacet.unpause.selector;
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(facet),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: functionSelectors
            })
        );
    }

    function setTradeFacet() private {
        TradeFacet facet = new TradeFacet();
        bytes4[] memory functionSelectors;
        functionSelectors = new bytes4[](5);
        functionSelectors[0] = TradeFacet.getPrice.selector;
        functionSelectors[1] = TradeFacet.buyShares.selector;
        functionSelectors[2] = TradeFacet.sellShares.selector;
        functionSelectors[3] = TradeFacet.sharesBalanceOf.selector;
        functionSelectors[4] = TradeFacet.getBuyPriceAfterFee.selector;
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(facet),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: functionSelectors
            })
        );
    }

    function setContentFacet() private {
        ContentFacet facet = new ContentFacet();
        bytes4[] memory functionSelectors;
        functionSelectors = new bytes4[](7);
        functionSelectors[0] = ContentFacet.post.selector;
        functionSelectors[1] = ContentFacet.like.selector;
        functionSelectors[2] = ContentFacet.reply.selector;
        functionSelectors[3] = ContentFacet.repost.selector;
        functionSelectors[4] = ContentFacet.postCountOf.selector;
        functionSelectors[5] = ContentFacet.postLikeCountOf.selector;
        functionSelectors[6] = ContentFacet.postReplyCountOf.selector;
        cut.push(
            IDiamondCut.FacetCut({
                facetAddress: address(facet),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: functionSelectors
            })
        );
    }
}
