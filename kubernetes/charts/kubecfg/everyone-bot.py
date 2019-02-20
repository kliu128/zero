from discord.ext import commands
import asyncio


class EveryoneBot:
    def __init__(self, bot):
        self.bot = bot

    async def message_screamer(self, message):
        channel = message.channel
        print("Got message from channel", channel, type(channel.id))
        if channel.id == "547787754314924037" and not message.author.id == self.bot.user.id:
            sent = await self.bot.send_message(channel, "@here")
            await asyncio.sleep(1)
            await self.bot.delete_message(sent)


def setup(bot):
    n = EveryoneBot(bot)
    bot.add_cog(n)
    bot.add_listener(n.message_screamer, "on_message")
