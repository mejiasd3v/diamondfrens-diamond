// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.21;

import "./utils/DiamondTest.sol";

contract ContentFacetTest is DiamondTest {
    ContentFacet facet;
    address user = makeAddr("user");

    string post1 = "Hello World";
    string post2 = unicode"The wait is over, and it's finally here! 🎉\n"
        unicode"I just dropped an exclusive interview with the\n" unicode"@code4rena rising star, \n"
        unicode"@MiloTruck.\n" unicode"You won't believe the insights and secrets revealed! 🕵️‍♂️ 🧵\n"
        unicode"(Either watch now or bookmark for later!)";

    event Post(address indexed author, uint256 indexed postId, uint256 createdAt, string content, uint256 parentPostId);

    function setUp() public {
        vm.startPrank(diamondOwner);
        DiamondFrens diamond = createDiamond();
        facet = ContentFacet(address(diamond));
        vm.stopPrank();

        console.log("user", user);
        vm.deal(user, 1 ether);
    }

    function test_post_UserCanCreatePostAndEventIsEmitted() public {
        vm.expectEmit();
        emit Post(user, 1, block.timestamp, post1, 0);

        vm.prank(user);
        facet.post(post1);

        assertEq(facet.postCountOf(user), 1, "Post count did not increase");
    }

    function test_post_UserCanCreateLongPost() public {
        vm.expectEmit();
        emit Post(user, 1, block.timestamp, post2, 0);

        vm.prank(user);
        facet.post(post2);

        assertEq(facet.postCountOf(user), 1, "Post count did not increase");
    }

    function test_reply_UserCanReplyAnExistingPost() public {
        address user2 = makeAddr("user2");

        vm.expectEmit();
        emit Post(user, 1, block.timestamp, post1, 0);
        emit Post(user2, 2, block.timestamp, post1, 1);

        vm.prank(user);
        facet.post(post1);

        vm.deal(user2, 1 ether);
        vm.prank(user2);
        facet.postReply(post2, 1);

        assertEq(facet.postCountOf(user), 1, "Post count did not increase");
        assertEq(facet.postReplyCountOf(1), 2, "Reply count did not increase");
    }

    function testFuzz_post(string calldata content) public {
        vm.prank(user);
        facet.post(content);
    }
}
