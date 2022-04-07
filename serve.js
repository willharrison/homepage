
const serveStatic = require('serve-static')
const chokidar = require('chokidar')
const express = require('express')
const app = express()
const exec = require('child_process').exec

app.use(serveStatic('dist', { index: ['index.html'] }))
app.listen(3000)

chokidar.watch('content').on('all', () => {
  exec('./build.sh')
})

chokidar.watch('templates').on('all', () => {
  exec('./build.sh')
})