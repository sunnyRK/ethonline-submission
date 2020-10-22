import { Component } from 'react';
import { getERCContractInstance, getPiggyBankContract } from '../../../../config/instances/contractinstances';
import web3 from '../../../../config/web3';
import PiggyBank from './PiggyBank';

class PiggyBankContainer extends Component {
  state = {
    totalEarnedPiggy: 0,
    totalSupply: 0,
    claimablePiggy: 0,
    loading: false,
  };

  async componentDidMount() {
    this.setState({ loading: true });
    const accounts = await web3.eth.getAccounts();
    const piggyBankContract = await getPiggyBankContract(web3);
    const ERCContractInstance = await getERCContractInstance(web3, '0xEF9371Ef592Dab0F73DB20E78b6B993B20E5D570'); // piggy token
    const totalEarnedPiggy = await ERCContractInstance.methods.balanceOf(accounts[0]).call();
    const totalSupply = await ERCContractInstance.methods.totalSupply().call();
    const claimablePiggy = await piggyBankContract.methods.pendingPiggy(0, accounts[0]).call();
    this.setState({
      totalEarnedPiggy,
      totalSupply,
      claimablePiggy: `${web3.utils.fromWei(claimablePiggy.toString(), 'ether')} Piggy`,
      loading: false,
    });
  }

  onClaimClick = async () => {
    try {
      this.setState({ loading: true });
      const accounts = await web3.eth.getAccounts();
      const piggyBankContract = await getPiggyBankContract(web3);
      await piggyBankContract.methods.withdrawAllNFT(0, accounts[0]).send({
        from: accounts[0],
      });
      this.setState({ loading: false });
    } catch (error) {
      this.setState({ loading: false });
    }
  }

  render() {
    return (
      <PiggyBank
        loading={this.state.loading}
        totalEarnedPiggy={this.state.totalEarnedPiggy}
        totalSupply={this.state.totalSupply}
        claimablePiggy={this.state.claimablePiggy}
        onClaimClick={this.onClaimClick}
      />
    );
  }
}

export default PiggyBankContainer;
