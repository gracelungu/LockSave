const LockSave = artifacts.require("LockSave.sol");

contract('LockSave', () => {
    let lockSave;
    let wallet;
    beforeEach(async () => {
        lockSave = await LockSave.new();
        web3.eth.getAccounts().then(accounts => {
            wallet = accounts[0];
        });
    });

    it('should create a single saving', async ()=>{
        const withdrawalTimestamp = 123456789;
        const amount = 1000;

        await lockSave.receiveSavings(withdrawalTimestamp, {value: amount});

        const totalSavings =  await lockSave.getUserTotalSavingAmount(wallet);
        assert(totalSavings == amount);
    });

    it('should create multiple savings', async ()=>{
        const withdrawalTimestamp = 123456789;
        const amounts = [1000, 2000];

        await Promise.all(amounts.map(async (amount) => {
            await lockSave.receiveSavings(withdrawalTimestamp, {value: amount});
        }));

        const totalSavings =  await lockSave.getUserTotalSavingAmount(wallet);
        assert(totalSavings.toNumber() === amounts.reduce((a, b) => a + b, 0));
    });

    it('should withdraw a saving', async () => {
        let totalSavings;
        const amount = 1000;
        const withdrawalTimestamp = new Date().getTime() - 1;

        await lockSave.receiveSavings(withdrawalTimestamp, {value: amount});
        const savingTimestamp = await lockSave.getSavingTimestamp(withdrawalTimestamp);
        
        totalSavings = await lockSave.getUserTotalSavingAmount(wallet);
        assert(totalSavings == amount);

        await lockSave.withdrawSavings(savingTimestamp);
        totalSavings =  await lockSave.getUserTotalSavingAmount(wallet);
        assert(totalSavings == 0);
    });

    it('should withdraws a saving before withdrawal time', async () => {
        let totalSavings;
        const amount = 1000;
        const withdrawalTimestamp = new Date().getTime() - 1;

        await lockSave.receiveSavings(withdrawalTimestamp, {value: amount});
        const savingTimestamp = await lockSave.getSavingTimestamp(withdrawalTimestamp);
        
        totalSavings = await lockSave.getUserTotalSavingAmount(wallet);
        assert(totalSavings == amount);

        await lockSave.earlySavingsWithdrawal(savingTimestamp);
    });
});