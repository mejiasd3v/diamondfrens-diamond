// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { AppStorage } from "../libraries/LibAppStorage.sol";
import { LibPausable } from "../libraries/LibPausable.sol";

/// @title PausationFacet
/// @notice Facet in charge of the pausation of certain features
/// @dev Utilizes 'LibDiamond', 'AppStorage' and 'LibPausable'
contract PausationFacet {
    AppStorage internal s;

    /// @notice Get if features are currently paused
    /// @return bool if features are paused
    function paused() external view returns (bool) {
        return s.paused;
    }

    /// @notice Pause features
    function pause() external {
        LibDiamond.enforceIsContractOwner();

        if (s.paused) revert LibPausable.AlreadyPaused();

        s.paused = true;
    }

    /// @notice Unpause features
    function unpause() external {
        LibDiamond.enforceIsContractOwner();

        if (!s.paused) revert LibPausable.AlreadyUnpaused();

        s.paused = false;
    }
}
