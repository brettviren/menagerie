#!/usr/bin/env python
'''
Import this to get access to various my python code
'''
import sys
import click
import functools
from subprocess import check_output
import logging
from pathlib import Path

# Want to auto-find my modules
me = Path(__file__)
sys.path.insert(0, str(me.parent / "python"))


def get_pass(name):
    '''
    Attempt to return a password of name from pass.
    '''
    got = check_output(["pass", name])
    return got.decode().split("\n")[0]


def context(group_name, log_name=None):
    '''
    Return a click group context decorator.

    To use, replace usual @click.group() with @context():
    
        from mypyco import context
        @context("groupname", "logname")
        def cli(ctx):
            pass

    If log_name is not given it defaults to group_name.

    To get the logger object either use:

        ctx.obj['log']

    or:

        log = logging.getLogger("logname")

    '''
    def decorator(func):
        cmddef = dict(context_settings=dict(help_option_names=['-h', '--help']))

        @click.group(group_name, **cmddef)
        @click.option("-l", "--log-output", multiple=True,
                      help="log to a file [default:stderr]")
        @click.option("-L", "--log-level", default="info",
                      help="set logging level [default:info]")
        @click.pass_context
        @functools.wraps(func)
        def wrapper(ctx, log_output, log_level, *args, **kwds):
            '''
            My Python Code command
            '''
            nonlocal log_name
            if not log_name:
                log_name = group_name
            log = logging.getLogger(log_name)
            try:
                level = int(log_level)      # try for number
            except ValueError:
                level = log_level.upper()   # else assume label
            log.setLevel(level)

            if not log_output:
                log_output = ["stderr"]
            for one in log_output:
                # print(f'logger {log_name} at level {log_level} to {one}')
                if one in ("stdout", "stderr"):
                    hand = logging.StreamHandler(getattr(sys, one))
                else:
                    hand = logging.FileHandler(one)
                hand.setLevel(level)
                log.addHandler(hand)
            ctx.obj = dict(log=log)
            return
        return wrapper
    return decorator


# what follows is just testing

@click.group()
def cli():
    pass


@cli.command("pass")
@click.argument("name")
def zx2c4(name):
    '''
    Run pass.
    '''
    print(get_pass(name))


if '__main__' == __name__:
    cli()
