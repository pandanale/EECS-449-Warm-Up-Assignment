from __future__ import annotations
from jaclang.plugin.feature import JacFeature as _Jac
from jaclang.plugin.builtin import *
from dataclasses import dataclass as __jac_dataclass__

@_Jac.make_walker(on_entry=[_Jac.DSFunc('return_message', _Jac.RootType)], on_exit=[])
@__jac_dataclass__(eq=False)
class interact(_Jac.Walker):

    def return_message(self, _jac_here_: _Jac.RootType) -> None:
        _Jac.report({'response': 'Hello, world!'})

@_Jac.make_walker(on_entry=[_Jac.DSFunc('return_message', _Jac.RootType)], on_exit=[])
@__jac_dataclass__(eq=False)
class interact_with_body(_Jac.Walker):
    name: str

    def return_message(self, _jac_here_: _Jac.RootType) -> None:
        _Jac.report({'response': 'Hello, ' + self.name + '!'})

@_Jac.make_walker(on_entry=[_Jac.DSFunc('return_message', _Jac.RootType)], on_exit=[])
@__jac_dataclass__(eq=False)
class reverse_string(_Jac.Walker):
    input: str

    def return_message(self, _jac_here_: _Jac.RootType) -> None:
        reversed = self.input[::-1]
        _Jac.report({'response': "The reverse of '" + self.input + "' is: '" + reversed + "'"})

@_Jac.make_walker(on_entry=[_Jac.DSFunc('return_message', _Jac.RootType)], on_exit=[])
@__jac_dataclass__(eq=False)
class calculate_sum(_Jac.Walker):
    num1: int
    num2: int

    def return_message(self, _jac_here_: _Jac.RootType) -> None:
        result = self.num1 + self.num2
        _Jac.report({'response': 'The sum of ' + str(self.num1) + ' and ' + str(self.num2) + ' is: ' + str(result)})