// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "./CinderlinkStrings.sol";

contract StringsTest is Test {
    function testSlugify() public pure {
        string memory slug = CinderlinkStrings.slugify("?test! 123. Foo?");
        require(
            keccak256(abi.encodePacked(slug)) == keccak256(abi.encodePacked("test--123--foo")),
            string.concat("'test 123' should sanitize to 'test-123'; result: ", slug)
        );
    }
}
