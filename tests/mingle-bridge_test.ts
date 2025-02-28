import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test event creation",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('mingle-bridge', 'create-event', [
                types.ascii("Beach Party"),
                types.ascii("Fun beach gathering"),
                types.uint(1625097600),
                types.ascii("Miami Beach"),
                types.ascii("Social")
            ], deployer.address)
        ]);
        
        assertEquals(block.receipts.length, 1);
        block.receipts[0].result.expectOk().expectUint(1);
        
        const response = chain.callReadOnlyFn(
            'mingle-bridge',
            'get-event-details',
            [types.uint(1)],
            deployer.address
        );
        
        response.result.expectOk().expectTuple();
    }
});

Clarinet.test({
    name: "Test RSVP functionality",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const user1 = accounts.get('wallet_1')!;
        
        // Create event
        chain.mineBlock([
            Tx.contractCall('mingle-bridge', 'create-event', [
                types.ascii("Tech Meetup"),
                types.ascii("Blockchain discussion"),
                types.uint(1625097600),
                types.ascii("Virtual"),
                types.ascii("Technology")
            ], deployer.address)
        ]);
        
        // Test RSVP
        let block = chain.mineBlock([
            Tx.contractCall('mingle-bridge', 'rsvp-event', 
                [types.uint(1), types.bool(true)],
                user1.address
            )
        ]);
        
        assertEquals(block.receipts.length, 1);
        block.receipts[0].result.expectOk().expectBool(true);
        
        // Verify RSVP status
        const response = chain.callReadOnlyFn(
            'mingle-bridge',
            'get-user-rsvp',
            [types.uint(1), types.principal(user1.address)],
            deployer.address
        );
        
        response.result.expectOk().expectBool(true);
    }
});

Clarinet.test({
    name: "Test user interests",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const user1 = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('mingle-bridge', 'set-interests',
                [types.list([types.ascii("Technology"), types.ascii("Social")])],
                user1.address
            )
        ]);
        
        assertEquals(block.receipts.length, 1);
        block.receipts[0].result.expectOk().expectBool(true);
        
        const response = chain.callReadOnlyFn(
            'mingle-bridge',
            'get-user-interests',
            [types.principal(user1.address)],
            user1.address
        );
        
        response.result.expectOk();
    }
});
