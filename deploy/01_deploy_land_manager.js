module.exports = async function ({ deployments, getNamedAccounts }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy('LandManager', {
    from: deployer,
    log: true,
    args: [0, 6, 0, 5],
  });
};

module.exports.tags = ['land_manager'];
