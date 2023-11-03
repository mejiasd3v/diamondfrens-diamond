// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AppStorage } from "./LibAppStorage.sol";

/// @title LibPausable
library LibPausable {
    error AlreadyPaused();
    error AlreadyUnpaused();
    error PausedFeature();

    /////////////
    /// LOGIC ///
    /////////////

    /// @notice Enforce feauture is paused
    /// @param s AppStorage
    function enforceIsUnpaused(AppStorage storage s) internal view {
        if (s.paused) revert PausedFeature();
    }

    /// @notice Pause the feature
    /// @param s AppStorage
    function pause(AppStorage storage s) internal {
        if (s.paused) revert AlreadyPaused();
        s.paused = true;
    }

    /// @notice Unpause the feature
    /// @param s AppStorage
    function unpause(AppStorage storage s) internal {
        if (!s.paused) revert AlreadyUnpaused();
        s.paused = false;
    }
}
