
function construct_lazytree(entry::AbstractEntry, rootconfig::AbstractROOTConfig)
    # get lazy tree
    filename = rootconfig.path_to_data * entry.runname * rootconfig.suffix
    rootfile = ROOTFile(filename)
    lz_tree = LazyTree(rootfile, rootconfig.treename, rootconfig.branches)

    return lz_tree

end
