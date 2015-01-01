module RedmineGitHosting
  module HookManager

    PACKAGE_HOOKS_DIR = Rails.root.join('plugins', 'redmine_git_hosting', 'contrib', 'hooks')

    POST_RECEIVE_HOOKS    = {
      'post-receive.redmine_gitolite.rb'   => { source: 'post-receive.redmine_gitolite.rb',   destination: 'post-receive',                      executable: true },
      'post-receive.git_multimail.py'      => { source: 'post-receive.git_multimail.py',      destination: 'post-receive.d/git_multimail.py',   executable: false },
      'post-receive.mail_notifications.py' => { source: 'post-receive.mail_notifications.py', destination: 'post-receive.d/mail_notifications', executable: true }
    }

    POST_RECEIVE_HOOK_DIR = [ 'post-receive.d' ]


    class << self

      def check_install!
        installed = {
          hook_dirs: hook_dirs_installed?,
          hook_files: hooks_installed?,
          global_params: global_params_installed?,
          mailer_params: mailer_params_installed?
        }
      end


      def update_hook_params!
        global_params_installed?
      end


      ### PRIVATE ###


      def hook_dirs_installed?
        installed = {}

        POST_RECEIVE_HOOK_DIR.each do |dir|
          hook_dir = HookDir.new(
            dir,
            destination_path(dir)
          )
          installed[hook_dir.name] = hook_dir.installed?
        end

        return installed
      end


      def hooks_installed?
        installed = {}

        POST_RECEIVE_HOOKS.each do |name, params|
          hook = HookFile.new(
            name,
            source_path(params[:source]),
            destination_path(params[:destination]),
            params[:executable]
          )
          installed[hook.name] = hook.installed?
        end

        return installed
      end


      def global_params_installed?
        return GlobalParams.new().installed?
      end


      def mailer_params_installed?
        return MailerParams.new().installed?
      end


      def gitolite_hooks_dir
        if RedmineGitHosting::Config.gitolite_version == 3
          File.join(RedmineGitHosting::Config.gitolite_home_dir, RedmineGitHosting::Config.gitolite_local_code_dir, 'hooks', 'common')
        else
          File.join(RedmineGitHosting::Config.gitolite_home_dir, '.gitolite', 'hooks', 'common')
        end
      end


      def destination_path(hook_dest_path)
        File.join(gitolite_hooks_dir, hook_dest_path)
      end


      def source_path(hook_source_path)
        File.join(PACKAGE_HOOKS_DIR, hook_source_path)
      end
    end

    private_class_method :hook_dirs_installed?,
                         :hooks_installed?,
                         :global_params_installed?,
                         :mailer_params_installed?,
                         :gitolite_hooks_dir,
                         :destination_path,
                         :source_path
  end
end
