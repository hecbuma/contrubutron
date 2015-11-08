require 'big_query'

opts = {}
opts['client_id']     = '240032106667-985gjakusi61b884a70fmig5ra3kvanr.apps.googleusercontent.com'
opts['service_email'] = '240032106667-985gjakusi61b884a70fmig5ra3kvanr@developer.gserviceaccount.com'
opts['key']           =  "#{Rails.root}/db/contributron-8abf8634daca.p12"
opts['project_id']    = 'contributron'


$bq = BigQuery::Client.new(opts)
