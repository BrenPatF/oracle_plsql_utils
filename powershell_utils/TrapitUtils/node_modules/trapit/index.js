const TrapitUtils = require('./lib/trapit-utils'),
      Trapit = require('./lib/trapit');

module.exports = {
    mkUTResultsFolderFromFile     : TrapitUtils.mkUTResultsFolderFromFile,
    mkUTExternalResultsFolders    : TrapitUtils.mkUTExternalResultsFolders,
    tabMkUTExternalResultsFolders : TrapitUtils.tabMkUTExternalResultsFolders,
    testUnit                      : TrapitUtils.testUnit,
    fmtTestUnit                   : TrapitUtils.fmtTestUnit,
    getUTResults                  : Trapit.getUTResults
}
