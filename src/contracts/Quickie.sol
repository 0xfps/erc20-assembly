// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

contract W {
    function _name() public pure returns (string memory) {
        // Return the name of the contract.
        assembly {
            mstore(0x00, 0x20)
            mstore(0x27, 0x07536561706f7274)
            return(0x00, 0x60)
        }
    }

    function hash() public pure returns (bytes memory) {
        return bytes("$STKN");
        // 0x536561706f7274
    }

    function read() public pure returns (string memory) {
        assembly {
            mstore(0x00, 0x20) // stores the string offset in memory location `0x00`
            mstore(0x20, 0x07) // Length
            mstore(0x40, shl(0xc8, 0x536561706f7274)) // Actual string, set at the start.
            return(0x00, 0x60) // Read from 0x00 to 0x00+0x60.
        }
    }
}
