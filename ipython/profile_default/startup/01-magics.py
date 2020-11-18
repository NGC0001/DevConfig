from IPython.core.magic import (register_line_magic, register_cell_magic,
                                register_line_cell_magic)


@register_line_magic
def nv(argline):
    '''nvim line magic'''
    return os.system(f'nvim {argline}')

# Resolve name conflicts.
del nv
