// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AppStorage } from "../libraries/LibAppStorage.sol";

contract ProfileFacet {
    AppStorage internal s;

    event Follow(address indexed follower, address indexed followee, uint256 createdAt);
    event Unfollow(address indexed follower, address indexed followee, uint256 createdAt);

    // Logic
    function follow(address _followee) external {
        emit Follow(msg.sender, _followee, block.timestamp);
    }

    function unfollow(address _followee) external {
        emit Unfollow(msg.sender, _followee, block.timestamp);
    }
}
