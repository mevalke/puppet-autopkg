define autopkg::autopkg_setup (
  $munki_repo,
  $autopkg_user,
  $cache_dir,
  $recipe_search_dirs,
  $recipe_override_dirs,
  $recipe_repo_dir,
  $recipe_repos,
  $recipes,
  $recipe_arr,
) {
  exec { "Setting Autopkg Munki Repository $munki_repo":
    command => "/usr/bin/defaults write com.github.autopkg MUNKI_REPO -string $munki_repo",
    onlyif  => "ls /usr/local/bin/autopkg && ls $munki_repo",
    unless  => "/usr/bin/defaults read com.github.autopkg MUNKI_REPO|grep $munki_repo",
    timeout => 0,
    path    => '/bin:/usr/bin:/usr/local/bin',
    user    => $autopkg_user,
  }
  exec { "Setting Autopkg Cache $cache_dir":
    command => "/usr/bin/defaults write com.github.autopkg CACHE_DIR -string $cache_dir",
    onlyif  => "ls /usr/local/bin/autopkg && ls $cache_dir",
    unless  => "/usr/bin/defaults read com.github.autopkg CACHE_DIR|grep $cache_dir",
    timeout => 0,
    path    => '/bin:/usr/bin:/usr/local/bin',
    user    => $autopkg_user,
  }
  exec { "Setting Autopkg Search Directory $recipe_search_dirs":
    command => "/usr/bin/defaults write com.github.autopkg RECIPE_SEARCH_DIRS -string $recipe_search_dirs",
    onlyif  => "ls /usr/local/bin/autopkg && ls $recipe_search_dirs",
    unless  => "/usr/bin/defaults read com.github.autopkg RECIPE_SEARCH_DIRS|grep $recipe_search_dirs",
    timeout => 0,
    path    => '/bin:/usr/bin:/usr/local/bin',
    user    => $autopkg_user,
  }
  exec { "Setting Autopkg Recipe Override Directory $recipe_override_dirs":
    command => "/usr/bin/defaults write com.github.autopkg RECIPE_OVERRIDE_DIRS -string $recipe_override_dirs",
    onlyif  => "ls /usr/local/bin/autopkg && ls $recipe_override_dirs",
    unless  => "/usr/bin/defaults read com.github.autopkg RECIPE_OVERRIDE_DIRS|grep $recipe_override_dirs",
    timeout => 0,
    path    => '/bin:/usr/bin:/usr/local/bin',
    user    => $autopkg_user,
  }
  exec { "Setting Autopkg Repository Directory $recipe_repo_dir":
    command => "/usr/bin/defaults write com.github.autopkg RECIPE_REPO_DIR -string $recipe_repo_dir",
    onlyif  => "ls /usr/local/bin/autopkg && ls $recipe_repo_dir",
    unless  => "/usr/bin/defaults read com.github.autopkg RECIPE_REPO_DIR|grep $recipe_repo_dir",
    timeout => 0,
    path    => '/bin:/usr/bin:/usr/local/bin',
    user    => $autopkg_user,
  }
  exec {"Updating Autopkg Recipes for Munki Repository $munki_repo":
    command => "/usr/local/bin/autopkg repo-add recipes",
    onlyif  => "ls /usr/local/bin/autopkg",
    timeout => 0,
    path    => '/bin:/usr/bin:/usr/local/bin',
    user    => $autopkg_user,
  }
  exec {"Adding additional Autopkg Recipes for Munki Repository $munki_repo":
    command => "/usr/local/bin/autopkg repo-add $recipe_repos",
    onlyif  => "ls /usr/local/bin/autopkg",
    timeout => 0,
    path    => '/bin:/usr/bin:/usr/local/bin',
    user    => $autopkg_user,
  }
  $recipe_arr.each|$recipe| {
    exec {"Adding Recipe Override $recipe_override_dirs/$recipe add_override":
      command => "autopkg make-override $recipe",
      unless  => "ls $recipe_override_dirs/$recipe",
      timeout => 0,
      path    => '/bin:/usr/bin:/usr/local/bin',
      user    => $autopkg_user,
      require => Exec["Adding additional Autopkg Recipes for Munki Repository $munki_repo"],
    }
  }    
  exec {"Running Autopkg Recipes for Munki Repository $munki_repo":
    command => "/usr/local/bin/autopkg run $recipes",
    onlyif  => "ls /usr/local/bin/autopkg",
    timeout => 0,
    path    => '/bin:/usr/bin:/usr/local/bin',
    user    => $autopkg_user,
  }
}

