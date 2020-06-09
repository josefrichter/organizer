defmodule Organizer.Mailer do

    def send_completion_notification(email \\ "", list_url \\ "") do
        IO.puts "Sending completion email to #{email}!"

        body = %{
              "FromEmail": "richter.josef+lists@gmail.com",
              "FromName": "TodoList App",
              "Subject": "Todo list is complete!",
              "MJ-TemplateID": "999902",
              "MJ-TemplateLanguage": true,
              "Vars": %{"name": "Todo"},
              "Recipients": [%{"Email": email}]
            }

        IO.inspect Mailjex.Delivery.send(body)

    end

end