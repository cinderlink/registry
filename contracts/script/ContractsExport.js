import minimist from "minimist";
import fs from "fs";
import path from "path";

const argv = minimist(process.argv.slice(2));

const chainIds = (argv.chainIds || "31337,84531,901").split(",");
const apps = (argv.apps || "swagmi,social-dapp").split(",");
const format = argv.format || "json";
const directories = [
  "../frontend/src/lib/contracts",
  ...apps.map((app) => `../../core/apps/${app}/src/lib/contracts`),
];

if (["json", "ts", "js"].indexOf(format) === -1) {
  throw new Error("Unknown format");
}

for (let directory of directories) {
  console.info(`exporting contracts to ${directory}/`);
  for (let chainId of chainIds) {
    const contracts = {};
    const chainDir = `${directory}/${chainId}`;
    const chainContractsDir = `${chainDir}/contracts`;
    if (fs.existsSync(chainContractsDir)) {
      fs.rmdirSync(chainContractsDir, { recursive: true });
    }
    fs.mkdirSync(chainContractsDir, { recursive: true });

    ["DeployAttestation.s.sol", "DeployNFT.s.sol", "Deploy.s.sol"].forEach(
      (script) => {
        const broadcastFile = path.resolve(
          "./broadcast/" + script + "/" + chainId + "/run-latest.json"
        );
        if (!fs.existsSync(broadcastFile)) {
          return;
        }
        console.info(`\t ${script} on ${chainId}:`);
        const artifact = JSON.parse(
          fs.readFileSync(
            "./broadcast/" + script + "/" + chainId + "/run-latest.json",
            "utf8"
          )
        );

        if (artifact && artifact.transactions) {
          for (let tx of artifact.transactions) {
            if (tx.contractName && tx.contractAddress) {
              const { abi } = JSON.parse(
                fs.readFileSync(
                  `./out/${tx.contractName}.sol/${tx.contractName}.json`,
                  "utf8"
                )
              );
              contracts[tx.contractName] = tx.contractAddress;
              const filename = `${chainContractsDir}/${tx.contractName}.${format}`;
              fs.writeFileSync(
                filename,
                format === "json"
                  ? JSON.stringify(
                      { abi, address: tx.contractAddress },
                      null,
                      2
                    )
                  : `export const ${tx.contractName} = {
  abi: ${JSON.stringify(abi)}, 
  address: "${tx.contractAddress}" 
};
export default ${tx.contractName};
`
              );
            }
          }
        }
      }
    );

    fs.writeFileSync(
      `${chainDir}/index.${format}`,
      format === "json"
        ? JSON.stringify(contracts, null, 2)
        : `
export const contracts = ${JSON.stringify(contracts, null, 2)};
export default contracts;

${Object.keys(contracts)
  .map(
    (contract) =>
      `export { default as ${contract} } from "./contracts/${contract}";`
  )
  .join("\n")}
`
    );
    console.info(
      `${
        Object.keys(contracts).length
      } contracts exported to ${chainDir}/index.${format}`
    );
  }

  if (format === "ts") {
    fs.writeFileSync(
      `${directory}/index.${format}`,
      `export default { ${chainIds
        .map((chainId) => `"${chainId}": () => import("./${chainId}"),`)
        .join(" ")} };`
    );
  }
}
