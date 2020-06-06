defmodule Todolists.Mailer do

    def send_completion_notification(email \\ "", list_url \\ "") do

        body = %{
              "FromEmail": "todolist@gmail.com",
              "FromName": "TodoList App",
              "Subject": "Todo list is complete!",
              "MJ-TemplateID": "999902",
              "MJ-TemplateLanguage": true,
              "Vars": %{"name": "Alice"},
              "Recipients": [%{"Email": email}]
            }

        Mailjex.Delivery.send(body)

    end

end