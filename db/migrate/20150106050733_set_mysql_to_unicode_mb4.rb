class SetMysqlToUnicodeMb4 < ActiveRecord::Migration
  # Converts the tables and strings columns to utf8mb4, which is the true, full
  # unicode support in MySQl

  def self.up
    # shorten indexes regardless of the RDBMS provider - for consitency
    shorten_indexes
    change_encoding('utf8mb4') if AppConfig.mysql?
  end

  def self.down
    change_encoding('utf8') if AppConfig.mysql?
  end

  def change_encoding(encoding)
    execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET #{encoding};"

    tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET = #{encoding}"
    end

    character_columns.each do |table, columns|
      columns.each do |column|
        execute "ALTER TABLE `#{table}` CHANGE `#{column.name}` `#{column.name}` #{column.sql_type} CHARACTER SET #{encoding} #{column.null ? 'NULL' : 'NOT NULL'} #{"DEFAULT '#{column.default}'" if column.has_default?};"
      end
    end
  end

  def character_columns
    # build a hash with all the columns that contain characters
    @character_columns ||= tables.map {|table|
      col = columns(table)
        .select {|column| column.type == :string || column.type == :text }
      next if col.empty?
      [table, col]
    }.compact.to_h
  end

  def shorten_indexes
    remove_index 'aspect_visibilities', :name => 'shareable_and_aspect_id'
    add_index 'aspect_visibilities', ["shareable_id", "shareable_type", "aspect_id"], :name => 'shareable_and_aspect_id', length: {"shareable_type"=>189}, :using => :btree

    remove_index 'aspect_visibilities', :name => 'index_aspect_visibilities_on_shareable_id_and_shareable_type'
    add_index 'aspect_visibilities', ["shareable_id", "shareable_type"], :name => 'index_aspect_visibilities_on_shareable_id_and_shareable_type', length: {"shareable_type"=>190}, :using => :btree

    remove_index 'chat_contacts', :name => 'index_chat_contacts_on_user_id_and_jid'
    add_index 'chat_contacts', ["user_id", "jid"], :name => 'index_chat_contacts_on_user_id_and_jid', length: {"jid"=>190}, :using => :btree, :unique => true

    remove_index 'comments', :name => 'index_comments_on_guid'
    add_index 'comments', ["guid"], :name => 'index_comments_on_guid', length: {"guid"=>191}, :using => :btree, :unique => true

    remove_index 'likes', :name => 'index_likes_on_guid'
    add_index 'likes', ["guid"], :name => 'index_likes_on_guid', length: {"guid"=>191}, :using => :btree, :unique => true

    remove_index 'o_embed_caches', :name => 'index_o_embed_caches_on_url'
    add_index 'o_embed_caches', ["url"], :name => 'index_o_embed_caches_on_url', length: {"url"=>191}, :using => :btree

    remove_index 'participations', :name => 'index_participations_on_guid'
    add_index 'participations', ["guid"], :name => 'index_participations_on_guid', length: {"guid"=>191}, :using => :btree

    remove_index 'people', :name => 'index_people_on_diaspora_handle'
    add_index "people", ["diaspora_handle"], :name => "index_people_on_diaspora_handle", :unique => true, :length => {"diaspora_handle" => 191}

    remove_index 'people', :name => 'index_people_on_guid'
    add_index 'people', ["guid"], :name => 'index_people_on_guid', length: {"guid"=>191}, :using => :btree, :unique => true

    remove_index 'photos', :name => 'index_photos_on_status_message_guid'
    add_index 'photos', ["status_message_guid"], :name => 'index_photos_on_status_message_guid', length: {"status_message_guid"=>191}, :using => :btree

    remove_index 'posts', :name => 'index_posts_on_guid'
    add_index 'posts', ["guid"], :name => 'index_posts_on_guid', length: {"guid"=>191}, :using => :btree, :unique => true

    remove_index 'posts', :name => 'index_posts_on_status_message_guid_and_pending'
    add_index 'posts', ["status_message_guid", "pending"], :name => 'index_posts_on_status_message_guid_and_pending', length: {"status_message_guid"=>190}, :using => :btree

    remove_index 'posts', :name => 'index_posts_on_status_message_guid'
    add_index 'posts', ["status_message_guid"], :name => 'index_posts_on_status_message_guid', length: {"status_message_guid"=>191}, :using => :btree

    remove_index 'posts', :name => 'index_posts_on_author_id_and_root_guid'
    add_index 'posts', ["author_id", "root_guid"], :name => 'index_posts_on_author_id_and_root_guid', length: {"root_guid"=>190}, :using => :btree, :unique => true

    remove_index 'posts', :name => 'index_posts_on_root_guid'
    add_index 'posts', ["root_guid"], :name => 'index_posts_on_root_guid', length: {"root_guid"=>191}

    remove_index 'rails_admin_histories', :name => 'index_rails_admin_histories'
    add_index 'rails_admin_histories', ["item", "table", "month", "year"], :name => 'index_rails_admin_histories', length: {"table"=>188}, :using => :btree

    remove_index 'schema_migrations', :name => 'unique_schema_migrations'
    add_index 'schema_migrations', ["version"], :name => 'unique_schema_migrations', length: {"version"=>191}, :using => :btree

    remove_index 'services', :name => 'index_services_on_type_and_uid'
    add_index 'services', ["type", "uid"], :name => 'index_services_on_type_and_uid', length: {"type"=>64, "uid"=>127}, :using => :btree

    remove_index 'taggings', :name => 'index_taggings_on_taggable_id_and_taggable_type_and_context'
    add_index 'taggings', ["taggable_id", "taggable_type", "context"], :name => 'index_taggings_on_taggable_id_and_taggable_type_and_context', length: {"taggable_type"=>95, "context"=>95}, :using => :btree

    remove_index 'tags', :name => 'index_tags_on_name'
    add_index 'tags', ["name"], :name => 'index_tags_on_name', length: {"name"=>191}, :using => :btree, :unique => true

    remove_index 'users', :name => 'index_users_on_invitation_service_and_invitation_identifier'
    add_index 'users', ["invitation_service", "invitation_identifier"], :name => 'index_users_on_invitation_service_and_invitation_identifier', length: {"invitation_service"=>64, "invitation_identifier"=>127}, :using => :btree, :unique => true

    remove_index 'users', :name => 'index_users_on_username'
    add_index 'users', ["username"], :name => 'index_users_on_username', length: {"username"=>191}, :using => :btree, :unique => true

    remove_index 'users', :name => 'index_users_on_email'
    add_index 'users', ["email"], :name => 'index_users_on_email', length: {"email"=>191}, :using => :btree

    remove_index 'notifications', :name => 'index_notifications_on_target_type_and_target_id'
    add_index 'notifications', ["target_type", "target_id"], name: 'index_notifications_on_target_type_and_target_id', length: {"target_type"=>190}, using: :btree
  end
end