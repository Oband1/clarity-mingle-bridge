// [Previous test content remains, adding new tests...]
Clarinet.test({
    name: "Test event creation with invalid timestamp",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('mingle-bridge', 'create-event', [
                types.ascii("Past Event"),
                types.ascii("Should fail"),
                types.uint(1),  // Past timestamp
                types.ascii("Anywhere"),
                types.ascii("Social"),
                types.uint(100)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectErr(104); // err-past-event
    }
});

// [Additional new tests...]
