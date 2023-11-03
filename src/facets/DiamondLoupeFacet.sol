// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IERC165 } from "../interfaces/IERC165.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

/// @title DiamondLoupeFacet
/// @author Modified from Nick Mudge: https://github.com/mudgen/diamond-3-hardhat
/// @notice Facet in charge of the diamond loupe
/// @dev Utilizes 'IDiamondLoupe', 'IERC165' and 'LibDiamond'
contract DiamondLoupeFacet is IDiamondLoupe, IERC165 {
    /// @notice Get all the facets within the diamond
    function facets() external view returns (Facet[] memory facets_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        uint256 numFacets = ds.facetAddresses.length;

        facets_ = new Facet[](numFacets);

        for (uint256 i; i < numFacets; ++i) {
            address facetAddress_ = ds.facetAddresses[i];

            facets_[i].facetAddress = facetAddress_;
            facets_[i].functionSelectors = ds.facetFunctionSelectors[facetAddress_].functionSelectors;
        }
    }

    /// @notice Get facet function selectors
    /// @param _facet Address of the facet
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        facetFunctionSelectors_ = ds.facetFunctionSelectors[_facet].functionSelectors;
    }

    /// @notice Get addresses of facets
    function facetAddresses() external view returns (address[] memory facetAddresses_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        facetAddresses_ = ds.facetAddresses;
    }

    /// @notice Get facet address of function selector
    /// @param _functionSelector Function selector
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        facetAddress_ = ds.selectorToFacetAndPosition[_functionSelector].facetAddress;
    }

    /// @notice Get if contract supports interface
    /// @param _id Interface ID
    function supportsInterface(bytes4 _id) external view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        return ds.supportedInterfaces[_id];
    }
}
