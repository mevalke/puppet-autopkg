class autopkg {
  $autopkg_url	       = lookup(autopkg::autopkg_url)
  $autopkg_folder      = "/Users/Shared/autopkg"
  $autopkg_user        = lookup(autopkg::autopkg_user)
  $autopkg_pw          = lookup(autopkg::autopkg_pw)
  $autopkg_ssh_key     = lookup(autopkg::autopkg_ssh_key)
  $repositories        = lookup(autopkg::repositories)
  $munki_server        = lookup(autopkg::munki_server)


  package {'autopkg':
    ensure   => installed,
    provider => pkgdmg,
    source   => "$autopkg_url",
  }

  File {
    owner => $autopkg_user,
    group => admin,
  }

  file { "$autopkg_folder": ensure     => directory }
  file { "$autopkg_folder/en": ensure  => directory }
  file { "$autopkg_folder/fi": ensure  => directory }
  file { "$autopkg_folder/log": ensure => file }

  exec { 'tunnel_smb_through_ssh_to_munki_server':
    command => "ssh -fNti /Users/$autopkg_user/.ssh/$autopkg_ssh_key -o 'StrictHostKeyChecking no' -L 139:127.0.0.1:139 $autopkg_user@$munki_server",
    path    => '/bin:/usr/bin:/sbin',
    unless  => "pgrep ssh",
  }

  $repositories.each|$repo, $param| {
    file {"/Volumes/$repo":
      ensure => directory,
      owner  => $autopkg_user,
    }
    exec { "mount $repo":
      command => "mount -t smbfs //$autopkg_user:$autopkg_pw@localhost/$repo /Volumes/$repo/",
      path    => '/bin:/usr/bin:/sbin',
      unless  => "ls /Volumes/$repo/pkgs",
      user    => $autopkg_user,
    }
  }

  $repositories.each|$repo, $param| {
    $recipe_repos = $param['recipe_repos']
    $recipes = $param['recipes']
    $recipe_arr = split($recipes, ' ')
    $full_recipe_arr = concat($recipe_arr, ['MakeCatalogs.munki.recipe'])
    if $repo != 'en' {
      $locale = $repo
    } else {
      $locale = undef
    }
    autopkg::autopkg_setup { $repo:
      munki_repo           => "/Volumes/$repo",
      autopkg_user         => $autopkg_user,
      cache_dir            => "$autopkg_folder/$repo/Cache",
      recipe_search_dirs   => "$autopkg_folder/$repo/Recipes",
      recipe_override_dirs => "$autopkg_folder/$repo/RecipeOverrides",
      recipe_repo_dir      => "$autopkg_folder/$repo/RecipeRepos",
      recipe_repos         => $recipe_repos,
      recipes              => "--post io.github.hjuutilainen.VirusTotalAnalyzer/VirusTotalAnalyzer --key LOCALE=$locale -k FAIL_RECIPES_WITHOUT_TRUST_INFO=no $recipes MakeCatalogs.munki.recipe",
      recipe_arr           => $full_recipe_arr,
    }
  }
}

