module.exports = async function ({ deployments, getNamedAccounts }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy('LandManager', {
    from: deployer,
    log: true,
    args: [5, 6],
  });
};

module.exports.tags = ['land_manager'];
