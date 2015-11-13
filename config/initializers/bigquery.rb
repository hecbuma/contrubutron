require 'big_query'

opts = {}
opts['client_id']     = '420342121869-compute@developer.gserviceaccount.com'
opts['service_email'] = 'account-1@ringed-bond-112715.iam.gserviceaccount.com'
opts['key']           =  "#{Rails.root}/db/Contributron-e74062760679.p12"
opts['project_id']    = 'ringed-bond-112715	'


$bq = BigQuery::Client.new(opts)
