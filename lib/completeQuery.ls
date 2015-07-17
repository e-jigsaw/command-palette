require! {
  path: {resolve}
  \atom-lson : {parseFile}
}

config = parseFile resolve __dirname, \../config.lson
aliases = {}
Object.keys config .forEach (pkg)->
  aliases[config[pkg].alias] = pkg

module.exports = (query)->
  query = query.split ' '
  if query.length > 1
    if aliases[query.0]? then query.0 = aliases[query.0]
    if query.1.length > 0
      if config[query.0]?.commands[query.1]? then query.1 = config[query.0].commands[query.1]
  query.join ' '
