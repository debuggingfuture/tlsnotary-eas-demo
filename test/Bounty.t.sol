// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "lib/eas-contracts/contracts/IEAS.sol";
import {MockUSD} from "../src/MockUSD.sol";
import {Bounty} from "../src/Bounty.sol";


// https://base-sepolia.easscan.org/schema/view/0x937f07b2538a23865e59d6f2a9a109b0e2da3dad79c8b6702b80cb15ebd8a9a7
// https://base-sepolia.easscan.org/attestation/view/0x3382c5d552720f468e140c92f026ebc1ea6c59e1e3e284c717c3944694c2466a
contract BountyTest is Test {
    Bounty public bounty;
    IEAS public eas;
    address constant easAddress = 0x4200000000000000000000000000000000000020;
    MockUSD public mockUSD;

    bytes32 attest_uid = bytes32(0xba1ff792766ef4a0ddec97a3297a85165c4dafeb65135d18f33364563b66f285);


    address hunter1;

    function setUp() public {
        bounty = new Bounty();
        hunter1 = makeAddr("hunter1");
        // TODO deploy mock eas
        eas = IEAS(address(easAddress));
        mockUSD = new MockUSD(1_000_000 * 10 ** 18);
    }

    function testAddPayee() public {
        uint256 balance = mockUSD.balanceOf(address(this));

        assert(balance == 1_000_000 * 10 ** 18);
        bounty.addPayee(hunter1, attest_uid);
        assertEq(bounty.shares(hunter1), 1);
    }
}
