defmodule Organizer.Mailer do
  def send_completion_notification(email \\ "", list_url \\ "") do
    IO.puts("Sending completion email to #{email}!")

    IO.inspect(
      body = %{
        FromEmail: "richter.josef+organizer@gmail.com",
        FromName: "Organizer App",
        Subject: "Todo list is complete!",
        "Text-part": "Dear #{email}, The todo list at #{list_url} is complete!",
        "Html-part":
          "<h3>Dear #{email},</h3><p>The todo list at <a href='#{list_url}'>#{list_url}</a> is complete!</h3>",
        #   "MJ-TemplateID": "999902",
        #   "MJ-TemplateLanguage": true,
        #   "Vars": %{"name": "Todo"},
        Recipients: [%{Email: email}]
      }
    )

    IO.inspect(Mailjex.Delivery.send(body))
  end
end
