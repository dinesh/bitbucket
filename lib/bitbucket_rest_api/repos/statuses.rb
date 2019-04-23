# encoding: utf-8

module BitBucket
  class Repos::Statuses < API

    # Add build status to commit
    #
    # = Parameters
    #  <tt>:user_name</tt> - Required string. The account of the repository owner.
    #  <tt>:repo_name</tt> - Required string. The repository name.
    #  <tt>:sha</tt> - Requrired string. The SHA1 value for the commit where you want to add the build status.
    #  <tt>:state</tt> - Required String. An indication of the status of the commit: (INPROGRESS, SUCCESSFUL, or FAILED)
    #  <tt>:key</tt> - Required String. A key that the vendor or build system supplies to identify the submitted build status.
    #  <tt>:url</tt> - Required String. The URL for the vendor or system that produces the build.
    #  <tt>:options</tt> Optional hash. Containing the following optional parameters:
    #     * <tt>description</tt> - A user-defined description of the build. For example, 4 out of 128 tests passed.
    #     * <tt>name<tt> - The name of the build. Your build system may provide the name, which will also appear in Bitbucket. For example, Unit Tests.
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.create_status(client.repos.statuses.create('homer',
    #                          'monorail',
    #                          'e14caad7c501e0ae52daef24b26aa2625b7534e6',
    #                          'SUCCESSFUL',
    #                          'BAMBOO-PROJECT-X',
    #                          'https://example.com/path/to/build/info',
    #                          'name' => 'this is covered by build_concurrency_spec',
    #                          'description' => 'Changes by John Doe')
    #
    def create(user_name, repo_name, sha, state, key, url, options = {})
       _update_user_repo_params(user_name, repo_name)
       _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of(sha, state, key, url)

      build_options = options.merge({
        "state" => state,
        "key" => key,
        "url" => url
      })

      url = if BitBucket.options[:bitbucket_server]
              # Endpoint is not referenced in the docs
              # https://docs.atlassian.com/bitbucket-server/rest/6.0.0/bitbucket-rest.html
              # but has been tested
              "/rest/build-status/1.0/commits/#{sha}"
            else
              "/2.0/repositories/#{user}/#{sanitize_repository_name(repo)}/commit/#{sha}/statuses/build"
            end

      faraday_options = { headers: { "Content-Type" => "application/json" } }
      post_request(url, build_options, faraday_options)
    end
  end # Repos::Statuses
end # BitBucket
