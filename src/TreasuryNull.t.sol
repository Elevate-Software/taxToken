// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/ds-test/src/test.sol";
import "./Utility.sol";

// Import sol file
import "./TaxToken.sol";
import "./Treasury.sol";

// Import interface.
import { IERC20, IUniswapV2Router01, IWETH } from "./interfaces/ERC20.sol";

contract TreasuryNullTest is Utility {

    // State variable for contract.
    TaxToken taxToken;
    Treasury treasury;
    address UNIV2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address UNIV2_PAIR = 0xf1d107ac566473968fC5A90c9EbEFe42eA3248a4;

    event LogUint(string s, uint u);
    event LogArrUint(string s, uint[] u);

    // Deploy token, specify input params.
    // setUp() runs before every tests conduct.
    function setUp() public {

        // Token instantiation.
        taxToken = new TaxToken(
            1000000000,                 // Initial liquidity
            'ProveZero',                // Name of token.
            'PROZ',                     // Symbol of token.
            18,                         // Precision of decimals.
            1000000,                    // Max wallet size
            100000                      // Max transaction amount
        );

        treasury = new Treasury(
            address(this), address(taxToken)
        );

        taxToken.setTreasury(address(treasury));


        // Set basisPointsTax for taxType 0 / 1 / 2
        // taxType 0 => Xfer Tax (10%)  => 10% (1wallets, marketing)
        // taxType 1 => Buy Tax (12%)   => 6%/6% (2wallets, use/marketing))
        // taxType 2 => Sell Tax (15%)  => 5%/4%/6% (3wallets, use/marketing/staking)
        taxToken.adjustBasisPointsTax(0, 1000);   // 1000 = 10.00 %
        taxToken.adjustBasisPointsTax(1, 1200);   // 1200 = 12.00 %
        taxToken.adjustBasisPointsTax(2, 1500);   // 1500 = 15.00 %

    }

    // Initial state check on treasury.
    // Each taxType (0, 1, and 2) should have some greater than 0 value.
    // The sum of all taxes accrued for each taxType should equal taxToken.balanceOf(treasury).
    // function test_treasury_initialState() public {
    //    //TODO: Test withdrawing funds ect with an empty treasury
    // }

    //Shameless stealing of other test cases

    // Initial state check on treasury.
    // Each taxType (0, 1, and 2) should all be equal to 0
    // The sum of all taxes accrued for each taxType should also be 0
    function test_nullTreasury_initialState() public {
        assert(treasury.taxTokenAccruedForTaxType(0) == 0);
        assert(treasury.taxTokenAccruedForTaxType(1) == 0);
        assert(treasury.taxTokenAccruedForTaxType(2) == 0);
        uint sum = treasury.taxTokenAccruedForTaxType(0) + treasury.taxTokenAccruedForTaxType(1) + treasury.taxTokenAccruedForTaxType(2);
        assertEq(sum, taxToken.balanceOf(address(treasury)));
    }

    // Test require statement fail: require(walletCount == wallets.length)
    function testFail_nullTreasury_modify_taxSetting_require_0() public {
        address[] memory wallets = new address[](3);
        address[] memory convertToAsset = new address[](2);
        uint[] memory percentDistribution = new uint[](2);
        
        wallets[0] = address(0);
        wallets[1] = address(1);
        wallets[2] = address(2);
        convertToAsset[0] = address(taxToken);
        convertToAsset[1] = address(taxToken);
        percentDistribution[0] = 50;
        percentDistribution[1] = 50;
        
        treasury.setTaxDistribution(
            0, 
            2, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );
    }

    // Test require statement fail: require(walletCount == convertToAsset.length)
    function testFail_nullTreasury_modify_taxSetting_require_1() public {
        address[] memory wallets = new address[](2);
        address[] memory convertToAsset = new address[](3);
        uint[] memory percentDistribution = new uint[](2);
        
        wallets[0] = address(0);
        wallets[1] = address(1);
        convertToAsset[0] = address(taxToken);
        convertToAsset[1] = address(taxToken);
        convertToAsset[2] = address(taxToken);
        percentDistribution[0] = 50;
        percentDistribution[1] = 50;
        
        treasury.setTaxDistribution(
            0, 
            2, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );
    }

    // Test require statement fail: require(walletCount == percentDistribution.length)
    function testFail_nullTreasury_modify_taxSetting_require_2() public {
        address[] memory wallets = new address[](2);
        address[] memory convertToAsset = new address[](2);
        uint[] memory percentDistribution = new uint[](3);
        
        wallets[0] = address(0);
        wallets[1] = address(1);
        convertToAsset[0] = address(taxToken);
        convertToAsset[1] = address(taxToken);
        percentDistribution[0] = 50;
        percentDistribution[1] = 49;
        percentDistribution[2] = 1;
        
        treasury.setTaxDistribution(
            0, 
            2, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );
    }

    // Test require statement fail: require(sumPercentDistribution == 100)
    function testFail_nullTreasury_modify_taxSetting_require_3() public {
        address[] memory wallets = new address[](2);
        address[] memory convertToAsset = new address[](2);
        uint[] memory percentDistribution = new uint[](2);
        
        wallets[0] = address(0);
        wallets[1] = address(1);
        convertToAsset[0] = address(taxToken);
        convertToAsset[1] = address(taxToken);
        percentDistribution[0] = 50;
        percentDistribution[1] = 49;
        
        treasury.setTaxDistribution(
            0, 
            2, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );
    }

    // Test that modifying taxSetting works (or initialization).
    // Perform initialization, then perform modification (two function calls).
    function test_nullTreasury_modify_taxSetting() public {
        address[] memory wallets = new address[](2);
        address[] memory convertToAsset = new address[](2);
        uint[] memory percentDistribution = new uint[](2);
        
        wallets[0] = address(0);
        wallets[1] = address(1);
        convertToAsset[0] = address(taxToken);
        convertToAsset[1] = address(taxToken);
        percentDistribution[0] = 50;
        percentDistribution[1] = 50;
        
        treasury.setTaxDistribution(
            0, 
            2, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );

        (
            uint256 _walletCount, 
            address[] memory _wallets, 
            address[] memory _convertToAsset, 
            uint[] memory _percentDistribution
        ) = treasury.viewTaxSettings(0);

        assertEq(_walletCount, 2);
        assertEq(_wallets[0], address(0));
        assertEq(_wallets[1], address(1));
        assertEq(_convertToAsset[0], address(taxToken));
        assertEq(_convertToAsset[1], address(taxToken));
        assertEq(_percentDistribution[0], 50);
        assertEq(_percentDistribution[1], 50);

        wallets = new address[](3);
        convertToAsset = new address[](3);
        percentDistribution = new uint[](3);
        
        wallets[0] = address(5);
        wallets[1] = address(6);
        wallets[2] = address(7);
        convertToAsset[0] = address(9);
        convertToAsset[1] = address(10);
        convertToAsset[2] = address(10);
        percentDistribution[0] = 30;
        percentDistribution[1] = 30;
        percentDistribution[2] = 40;
        
        treasury.setTaxDistribution(
            0, 
            3, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );

        (
            _walletCount, 
            _wallets, 
            _convertToAsset, 
             _percentDistribution
        ) = treasury.viewTaxSettings(0);

        assertEq(_walletCount, 3);
        assertEq(_wallets[0], address(5));
        assertEq(_wallets[1], address(6));
        assertEq(_wallets[2], address(7));
        assertEq(_convertToAsset[0], address(9));
        assertEq(_convertToAsset[1], address(10));
        assertEq(_convertToAsset[2], address(10));
        assertEq(_percentDistribution[0], 30);
        assertEq(_percentDistribution[1], 30);
        assertEq(_percentDistribution[2], 40);
    }

    // Test distributing taxes when none exist in wallet
    function test_nullTreasury_taxDistribution() public {

        address[] memory wallets = new address[](2);
        address[] memory convertToAsset = new address[](2);
        uint[] memory percentDistribution = new uint[](2);
        
        wallets[0] = address(0);
        wallets[1] = address(1);
        convertToAsset[0] = address(taxToken);
        convertToAsset[1] = address(taxToken);
        percentDistribution[0] = 50;
        percentDistribution[1] = 50;
        
        treasury.setTaxDistribution(
            1, 
            2, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );

        assertEq(treasury.distributeTaxes(1), 0);
    }

    // Test converting tokens when none exist
    function test_nullTreasury_taxDistribution_conversion() public {

        address[] memory wallets = new address[](2);
        address[] memory convertToAsset = new address[](2);
        uint[] memory percentDistribution = new uint[](2);
        
        wallets[0] = address(0);
        wallets[1] = address(1);
        convertToAsset[0] = address(taxToken);
        convertToAsset[1] = WETH;
        percentDistribution[0] = 50;
        percentDistribution[1] = 50;
        
        treasury.setTaxDistribution(
            1, 
            2, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );

        assertEq(treasury.distributeTaxes(1), 0);
    }

    // function test_treasury_scuffedDistribution() public {
        
    //     // set treasury initial state
    //     treasury_setDistribution();
    //     create_lp();
    //     taxToken.modifyWhitelist(address(treasury), true);

    //     // pre state check
    //     assertEq(treasury.taxTokenAccruedForTaxType(0), 0);
    //     assertEq(treasury.taxTokenAccruedForTaxType(1), 0);
    //     assertEq(treasury.taxTokenAccruedForTaxType(2), 0);

    //     uint preBal = IERC20(WETH).balanceOf(address(11));
    //     uint preBal2 = IERC20(WETH).balanceOf(address(12));
    //     uint preBal3 = IERC20(WETH).balanceOf(address(13));
    //     uint preBal4 = IERC20(WETH).balanceOf(address(14));

    //     // load treasury up with tokens
    //     taxToken.transfer(address(treasury), 30 ether);
    //     treasury.updateTaxesAccrued(0, 30 ether);
    //     treasury.setDistributionThreshold(30);
    //     taxToken.transfer(address(treasury), 10 ether);
    //     treasury.updateTaxesAccrued(0, 10 ether); // sends contract over threshold thus distributing

    //     // post state check
    //     assertEq(treasury.taxTokenAccruedForTaxType(0), 0);
    //     assertEq(treasury.taxTokenAccruedForTaxType(1), 0);
    //     assertEq(treasury.taxTokenAccruedForTaxType(2), 0);

    //     assertEq(IERC20(WETH).balanceOf(address(11))-preBal, treasury.royaltiesDistributed_WETH(address(11)));
    //     assertEq(IERC20(WETH).balanceOf(address(12))-preBal2, treasury.royaltiesDistributed_WETH(address(12)));
    //     assertEq(IERC20(WETH).balanceOf(address(13))-preBal3, treasury.royaltiesDistributed_WETH(address(13)));
    //     assertEq(IERC20(WETH).balanceOf(address(14))-preBal4, treasury.royaltiesDistributed_WETH(address(14)));

    //     // sequence 2

    //     preBal = IERC20(WETH).balanceOf(address(11));
    //     preBal2 = IERC20(WETH).balanceOf(address(12));
    //     preBal3 = IERC20(WETH).balanceOf(address(13));
    //     preBal4 = IERC20(WETH).balanceOf(address(14));

    //     // load treasury up with tokens
    //     taxToken.transfer(address(treasury), 31 ether);
    //     treasury.updateTaxesAccrued(0, 31 ether); // distribute

    //     // post state check
    //     assertEq(treasury.taxTokenAccruedForTaxType(0), 0);
    //     assertEq(treasury.taxTokenAccruedForTaxType(1), 0);
    //     assertEq(treasury.taxTokenAccruedForTaxType(2), 0);

    //     assertEq(IERC20(WETH).balanceOf(address(11)), treasury.royaltiesDistributed_WETH(address(11)));
    //     assertEq(IERC20(WETH).balanceOf(address(12)), treasury.royaltiesDistributed_WETH(address(12)));
    //     assertEq(IERC20(WETH).balanceOf(address(13)), treasury.royaltiesDistributed_WETH(address(13)));
    //     assertEq(IERC20(WETH).balanceOf(address(14)), treasury.royaltiesDistributed_WETH(address(14)));
    // }

    function treasury_setDistribution() public {
        address[] memory wallets = new address[](4);
        address[] memory convertToAsset = new address[](4);
        uint[] memory percentDistribution = new uint[](4);

        wallets[0] = address(11);
        wallets[1] = address(12);
        wallets[2] = address(13);
        wallets[3] = address(14);
        convertToAsset[0] = WETH;
        convertToAsset[1] = WETH;
        convertToAsset[2] = WETH;
        convertToAsset[3] = WETH;
        percentDistribution[0] = 40;
        percentDistribution[1] = 30;
        percentDistribution[2] = 20;
        percentDistribution[3] = 10;

        // (14, 15, 16) Update TaxType 0, 1, 2.
        treasury.setTaxDistribution(
            0, 
            4, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );

        treasury.setTaxDistribution(
            1, 
            4, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );

        treasury.setTaxDistribution(
            2, 
            4, 
            wallets, 
            convertToAsset, 
            percentDistribution
        );
    }

    function create_lp() public {
        // Convert our ETH to WETH
        uint ETH_DEPOSIT = 100 ether;
        uint TAX_DEPOSIT = 10000 ether;

        IWETH(WETH).deposit{value: ETH_DEPOSIT}();

        IERC20(WETH).approve(
            address(UNIV2_ROUTER), ETH_DEPOSIT
        );
        IERC20(address(taxToken)).approve(
            address(UNIV2_ROUTER), TAX_DEPOSIT
        );

        taxToken.modifyWhitelist(address(this), true);

        // Instantiate liquidity pool.
        // TODO: Research params for addLiquidityETH (which one is for TaxToken amount?).
        IUniswapV2Router01(UNIV2_ROUTER).addLiquidityETH{value: ETH_DEPOSIT}(
            address(taxToken),
            TAX_DEPOSIT,            // This variable is the TaxToken amount to deposit.
            10 ether,
            10 ether,
            address(this),
            block.timestamp + 300
        );
    }
    
}