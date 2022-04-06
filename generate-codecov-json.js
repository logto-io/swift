// From https://github.com/sersoft-gmbh/swift-coverage-action
// See https://github.com/codecov/uploader/issues/223 for why this file exists
/*
name: generate-codecov-json.js
purpose: convert .xcresult coverage data to codecov json format
example: node generate-codecov-json.js --archive-path SOME_PATH/SOME.xcresult

note:
you'll need to build and test w/ coverage. example:
> xcodebuild -scheme xcode-poc  -sdk iphonesimulator -derivedDataPath Build/ -destination 'id=09CE93EF-52C4-49AA-8C7F-B10B8CC016E0' -enableCodeCoverage YES clean test
*/

const fs = require('fs')
const { argv } = require('yargs')
const { execSync } = require('child_process')

const { log } = console

const archivePath = argv['archive-path']
const prefix = argv.prefix

const report = { coverage: {} }

getFileList(archivePath).forEach(file => {
  const coverageInfo = getCoverageInfo(file)
  const coverageJson = convertCoverage(coverageInfo)
  const repoFilePath = file.replace(prefix, '')
  report.coverage[repoFilePath] = coverageJson
})

const tmp = archivePath.split('/').pop().split('.xcresult')[0]

fs.writeFileSync(`./coverage-report-${tmp}.json`, JSON.stringify(report))

log('done.')

function getFileList(archivePath) {
  const fileListCmd = 'xcrun xccov view --file-list --archive'
  const fileListStr = execSync(`${fileListCmd} ${archivePath}`, { stdio: [process.stdout] }).toString()
  return fileListStr.split('\n').filter(i => i !== '')
}

function getCoverageInfo(filePath) {
  return execSync(`xcrun xccov view --archive ${archivePath} --file ${filePath}`, { stdio: [process.stdout] }).toString()
}

function convertCoverage(coverageInfo) {
  const coverageInfoArr = coverageInfo.split('\n')
  const obj = {}
  coverageInfoArr.forEach(line => {
    const [lineNum, lineInfo] = line.split(':')
    if (lineNum && Number.isInteger(Number(lineNum))) {
      const lineHits = lineInfo.trimStart().split(' ')[0].trim()
      if (lineHits === '*') {
        obj[String(lineNum.trim())] = null
      } else {
        obj[String(lineNum.trim())] = lineHits
      }
    }
  })
  return obj
}
