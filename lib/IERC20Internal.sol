// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

abstract contract IERC20Internal {
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual;

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual;

    function _mint(address account, uint256 amount) internal virtual;
}
