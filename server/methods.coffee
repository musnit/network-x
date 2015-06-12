@Neo4j = new Neo4jDB()
stringify = Neo4j.stringify.bind(Neo4j)

Meteor.methods
  # A method to search :Person ##
  searchPeople: (name, others...) ->
    # Matches any :Person node with the name inputted (case sensitive, not fuzzy)
    nodesA = Neo4j.query "MATCH (a:Person {name:'#{name}'})-[]-() RETURN DISTINCT {name:a.name, label:labels(a)[0], id:id(a)} as nodes"
    nodesB = Neo4j.query "MATCH (:Person {name:'#{name}'})-[]-(b) RETURN DISTINCT {name:b.name, label:labels(b)[0], id:id(b)} as nodes"
    nodes = nodesA.concat(nodesB) ## TODO there must be a way to do this in one query...

    linkIds = Neo4j.query "MATCH (a:Person {name:'#{name}'})-[r]-(b) RETURN {source:id(a), target:id(b), type:type(r)} as links"
    links = createLinks linkIds, R.pluck('id')(nodes)

    return graph = { links:links, nodes:nodes }

  ## A method to search :Company ##
  searchCompany: (name, industry, others...) ->
    # Matches all companies that contain the proper name
    if name
      nodesA = Neo4j.query "MATCH (a:Company {name:'#{name}'})-[]-() RETURN DISTINCT {name:a.name, label:labels(a)[0], id:id(a)} as nodes"
      nodesB = Neo4j.query "MATCH (:Company {name:'#{name}'})-[]-(b) RETURN DISTINCT {name:b.name, label:labels(b)[0], id:id(b)} as nodes"
      nodes = nodesA.concat(nodesB) ## TODO there must be a way to do this in one query...

      linkIds = Neo4j.query "MATCH (a:Company {name:'#{name}'})-[r]-(b) RETURN {source:id(a), target:id(b), type:type(r)} as links"
      links = createLinks linkIds, R.pluck('id')(nodes)

      return graph = { links:links, nodes:nodes }

    # Matches all companies that contain the industry
    if industry
      nodesA = Neo4j.query "MATCH (a:Company)-[]-() WHERE '#{industry}' in a.industry RETURN DISTINCT {name:a.name, label:labels(a)[0], id:id(a)} as nodes"
      nodesB = Neo4j.query "MATCH (a:Company)-[]-(b) WHERE '#{industry}' in a.industry RETURN DISTINCT {name:b.name, label:labels(b)[0], id:id(b)} as nodes"
      nodes = nodesA.concat(nodesB) ## TODO there must be a way to do this in one query...

      linkIds = Neo4j.query "MATCH (a:Company)-[r]-(b) WHERE '#{industry}' in a.industry RETURN {source:id(a), target:id(b), type:type(r)} as links"
      links = createLinks linkIds, R.pluck('id')(nodes)

      return graph = { links:links, nodes:nodes }

  getGraph: () ->
    ## Returns all data in the graph ##
    nodes = Neo4j.query "MATCH (a) RETURN {name:a.name, label:labels(a)[0], id:id(a)} as nodes"

    linkIds = Neo4j.query "MATCH (a)-[r]->(b) RETURN {source:id(a), target:id(b), type:type(r)} as links"

    ## createLinks takes in a link with ids and the full node list, then converts
    ## it to something that D3 can use: array indeces
    links = createLinks linkIds, R.pluck('id')(nodes)

    return graph = { links:links, nodes:nodes }
