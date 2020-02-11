const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
  try {
    await exec.exec('sh', ['entrypoint.sh']);
  }
  catch (error) {
    core.setFailed(error.message);
  }
}

run()
