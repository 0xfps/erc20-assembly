// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SunToken is IERC20 {
    mapping(address => uint256) private _balances; // 0

    mapping(address => mapping(address => uint256)) private _allowances; // 1

    uint256 private _totalSupply; // 2

    string private _name; // 3
    string private _symbol; // 4

    constructor() {
        uint256 tot = 1e27;
        _mint(msg.sender, tot);
        approve(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 1000);
    }

    function name() public pure returns (string memory) {
        // 0x53756e20546f6b656e
        // Sun Token
        assembly {
            mstore(0x0, 0x20)
            mstore(0x29, 0x0953756e20546f6b656e)
            return(0x0, 0x60)
        }
    }

    function symbol() public pure returns (string memory) {
        // 0x2453544b4e
        // $STKN
        assembly {
            mstore(0x0, 0x20)
            mstore(0x25, 0x052453544b4e)
            return(0x20, 0x60)
        }
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        assembly {
            mstore(0x40, sload(2))
            return(0x40, 0x20)
        }
    }

    function balanceOf(address account) public view returns (uint256 bal) {
        bytes32 balanceLocation = keccak256(abi.encode(account, 0));
        
        assembly {
            if iszero(and(account, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            bal := sload(balanceLocation)
        }
    }

    function transfer(address to, uint256 amount) public returns (bool sent) {
        bytes32 senderLocation = keccak256(abi.encode(msg.sender, 0));
        bytes32 receiverLocation = keccak256(abi.encode(to, 0));

        assembly {
            if iszero(and(
                caller(), 
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )){
                revert(0, 0)
            }

            // Load sender's balance.
            let senderBal := sload(senderLocation)
            // Load receiver's balance.
            let receiverBal := sload(receiverLocation)

            if gt(amount, senderBal) {
                revert(0, 0)
            }

            if lt(add(receiverBal, amount), receiverBal) {
                revert(0, 0)
            }

            if gt(sub(senderBal, amount), senderBal) {
                revert(0, 0)
            }

            sstore(senderLocation, sub(senderBal, amount))
            sstore(receiverLocation, add(receiverBal, amount))
            sent := 1
        }
    }

    function allowance(address owner, address spender) public view returns (uint256 all) {
        bytes32 allowanceLoc = keccak256(abi.encode(spender, keccak256(abi.encode(owner, 1))));

        assembly {
            all := sload(allowanceLoc)
        }
    }

    function approve(address spender, uint256 amount) public returns (bool t) {
        bytes32 allowanceLoc = keccak256(abi.encode(spender, keccak256(abi.encode(msg.sender, 1))));

        assembly {
            if iszero(and(caller(), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            if iszero(and(spender, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            let currentAllowance := sload(allowanceLoc)

            if lt(add(currentAllowance, amount), currentAllowance) {
                revert(0, 0)
            }

            sstore(allowanceLoc, add(currentAllowance, amount))
            t := 1
        }
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool t) {
        bytes32 allowanceLoc = keccak256(abi.encode(msg.sender, keccak256(abi.encode(from, 1))));

        bytes32 senderLocation = keccak256(abi.encode(from, 0));
        bytes32 receiverLocation = keccak256(abi.encode(to, 0));

        assembly {
            if iszero(and(caller(), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            if iszero(and(from, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            if iszero(and(to, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            let currentAllowance := sload(allowanceLoc)

            if lt(currentAllowance, amount) {
                revert(0, 0)
            }

            if gt(sub(currentAllowance, amount), currentAllowance) {
                revert(0, 0)
            }

            // Load sender's balance.
            let senderBal := sload(senderLocation)
            // Load receiver's balance.
            let receiverBal := sload(receiverLocation)

            if gt(amount, senderBal) {
                revert(0, 0)
            }

            if lt(add(receiverBal, amount), receiverBal) {
                revert(0, 0)
            }

            if gt(sub(senderBal, amount), senderBal) {
                revert(0, 0)
            }

            sstore(senderLocation, sub(senderBal, amount))
            sstore(receiverLocation, add(receiverBal, amount))
            

            sstore(allowanceLoc, sub(currentAllowance, amount))
            t := 1
        }
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool t) {
        bytes32 allowanceLoc = keccak256(abi.encode(spender, keccak256(abi.encode(msg.sender, 1))));

        assembly {
            if iszero(and(caller(), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            if iszero(and(spender, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            let currentAllowance := sload(allowanceLoc)

            if lt(add(currentAllowance, addedValue), currentAllowance) {
                revert(0, 0)
            }

            sstore(allowanceLoc, add(currentAllowance, addedValue))
            t := 1
        }
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool t) {
        bytes32 allowanceLoc = keccak256(abi.encode(spender, keccak256(abi.encode(msg.sender, 1))));

        assembly {
            if iszero(and(caller(), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            if iszero(and(spender, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            let currentAllowance := sload(allowanceLoc)

            if gt(sub(currentAllowance, subtractedValue), currentAllowance) {
                revert(0, 0)
            }

            sstore(allowanceLoc, add(currentAllowance, subtractedValue))
            t := 1
        }
    }

    function _mint(address account, uint256 amount) internal {
        bytes32 balanceLocation = keccak256(abi.encode(account, 0));
        
        assembly {
            if iszero(and(account, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            let bal := sload(balanceLocation)
            let ts := sload(2)

            if lt(add(bal, amount), bal) {
                revert(0, 0)
            }

            if lt(add(ts, amount), ts) {
                revert(0, 0)
            }

            sstore(balanceLocation, add(bal, amount))
            sstore(2, add(ts, amount))
        }
    }

    function _burn(address account, uint256 amount) internal virtual {
        bytes32 balanceLocation = keccak256(abi.encode(account, 0));
        
        assembly {
            if iszero(and(account, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)){
                revert(0, 0)
            }

            let bal := sload(balanceLocation)
            let ts := sload(2)

            if gt(sub(bal, amount), bal) {
                revert(0, 0)
            }

            if gt(sub(ts, amount), ts) {
                revert(0, 0)
            }

            sstore(balanceLocation, sub(bal, amount))
            sstore(2, sub(ts, amount))
        }
    }
}