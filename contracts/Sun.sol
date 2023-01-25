// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

contract SunToken {
    mapping(address => uint256) private _balances; // 0

    mapping(address => mapping(address => uint256)) private _allowances; // 1

    uint256 private _totalSupply; // 2

    string private _name; // 3
    string private _symbol; // 4


    // constructor(string memory name_, string memory symbol_) {
    constructor() {
        string memory name_ = "FPS";
        string memory symbol_ = "SOL";

        assembly {
            let nameLength := mload(name_)
            let symbolLength := mload(symbol_)

            sstore(3, mload(add(name_, 0x20)))
            sstore(4, mload(add(symbol_, 0x20)))
        }

        _balances[msg.sender] = 2000;
        approve(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 1000);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
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