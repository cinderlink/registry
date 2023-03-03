import minimist from "minimist";
import { globby } from "globby";
import fs from "fs";

const toCopy = await globby(["./docs/src/src/Registry/*.sol/contract.*.md"]);
const regexp = /\/contract\.(.*)\.md$/;
const linkRegexp = /\[(.+)\]\(\/src\/Registry\/(.*)\.sol\/contract\.(.*)\)/g;

toCopy.filter(file => !file.endsWith("Test.md")).forEach((file) => {
    const match = file.match(regexp);
    if (match) {
        const [, name] = match;
        const source = fs.readFileSync(file, "utf8");

        const modified = source.replaceAll(linkRegexp, (match, text, contract, _, method) => {
            console.info(`replacing ${match} with [${text}](/contracts/${contract}#${method})`);
            return `[${text}](/contracts/${contract}#${method})`;
        });

        fs.writeFileSync(`../frontend/src/routes/contracts/${name}.md`, modified);
        console.info(`copied ${name} docs to ../frontend/src/routes/contracts/${name}.md`)
    }
});