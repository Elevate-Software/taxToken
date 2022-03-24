// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/ds-test/src/test.sol";
import "./Utility.sol";

// Import sol file
import "./TaxToken.sol";
import "./Treasury.sol";

// Import interface.
import { IERC20, IUniswapV2Router01, IWETH } from "./interfaces/ERC20.sol";

contract TaxTokenTest is Utility {

    // State variable for contract.
    TaxToken taxToken;
    Treasury treasury;

    event LogUint(string s, uint u);

    // Deploy token, specify input params.
    // setUp() runs before every tests conduct.
    function setUp() public {
        taxToken = new TaxToken(
            1000 ether,
            'Darpa',
            'DRPK',
            18,
            address(this)
        );
        treasury = new Treasury(
            address(this), address(taxToken)
        );
        taxToken.setTreasury(address(treasury));
        taxToken.adjustBasisPointsTax(0, 10000);

        // Convert our ETH to WETH
        uint depositAmt = 100 ether;
        IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).deposit{value: depositAmt}();
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).approve(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), depositAmt
        );
        IERC20(address(taxToken)).approve(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), depositAmt
        );

        // Instantiate liquidity pool.
        IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D).addLiquidityETH{value: depositAmt}(
            address(taxToken),
            5 ether,
            10 ether,
            10 ether,
            address(this),
            block.timestamp + 300
        );
    }

    function test_lp_state() public {
        // How many LP tokens are there
        // How much ETH and TT are present in the pool itself
    }

    function test_lp_buy() public {
        // Converting ETH to taxToken via LP
    }

    function test_lp_sell() public {
        // Converting taxToken to ETH via LP
    }

    function test_lp_buy_tax() public {
        // Converting ETH to taxToken via LP
    }

    function test_lp_sell_tax() public {
        // Converting taxToken to ETH via LP
    }

}