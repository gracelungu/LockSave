const LockSave = artifacts.require("LockSave.sol");

contract('LockSave', () => {
    let lockSave;
    beforeEach(async () => {
        lockSave = await LockSave.new();
    });

    it('should create a saving', async ()=>{
        await lockSave.receiveSavings(1234567);
        const totalSavings =  await lockSave.getUserTotalSavingAmount('0x123456');
        console.log(totalSavings);
        assert(totalSavings.toNumber() === 1234567);
    });
});