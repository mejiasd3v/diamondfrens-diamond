// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

uint256 constant DEFAULT_WEIGHT_A = 80 ether / 100;
uint256 constant DEFAULT_WEIGHT_B = 50 ether / 100;
uint256 constant DEFAULT_WEIGHT_C = 2;
uint256 constant DEFAULT_WEIGHT_D = 0;

struct AppStorage {
    /////////////////////
    /// AUTHORIZATION ///
    /////////////////////
    mapping(address => bool) authorized;
    /////////////////
    /// PAUSATION ///
    /////////////////
    bool paused;
    /////////////
    /// TRADE ///
    /////////////
    mapping(address => uint256) sharesSupplyOf;
    mapping(address => mapping(address => uint256)) sharesBalanceOf;
    mapping(address => uint256) tvlOf;
    mapping(address => address) userToReferrer;
    uint256 initialPrice;
    uint256 protocolFeePercent;
    uint256 subjectFeePercent;
    uint256 referralFeePercent;
    address protocolFeeDestination;
    address protocolFeeDestination2;
    ///////////////
    /// CONTENT ///
    ///////////////
    mapping(address => uint256) postCountOf;
    mapping(uint256 => uint256) postLikeCountOf;
    mapping(address => mapping(uint256 => bool)) likedPostsOf;
    mapping(uint256 => uint256) postReplyCountOf;
}
