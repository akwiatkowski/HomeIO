# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

# used for universal raphael graphs
#Mime::Type.register_alias "text/html", :html_graph
Mime::Type.register_alias "application/json", :json_graph
Mime::Type.register_alias "text/plain", :txt
Mime::Type.register_alias "image/png", :png
Mime::Type.register_alias "image/svg+xml", :svg

# simpler type of json response
Mime::Type.register_alias "application/json", :json_autorefresh

