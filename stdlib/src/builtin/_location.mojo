# ===----------------------------------------------------------------------=== #
# Copyright (c) 2024, Modular Inc. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ===----------------------------------------------------------------------=== #
"""Implements the source range struct.
"""


@value
@register_passable("trivial")
struct _SourceLocation(Stringable):
    var file_name: StringLiteral
    var function_name: StringLiteral
    var line: Int

    fn __str__(self) -> String:
        return (
            str(self.file_name)
            + ":"
            + str(self.function_name)
            + ":"
            + str(self.line)
        )


@value
@register_passable("trivial")
struct _SourceLocInfo:
    """Type to carry file name, line, and column information."""

    var line: Int
    var col: Int
    var file_name: StringLiteral


@always_inline("nodebug")
fn __source_loc() -> _SourceLocInfo:
    """Returns the location where it's called.

    This currently doesn't work when called in a parameter expression.

    Returns:
        The location information of the __source_loc() call.
    """
    var line: __mlir_type.index
    var col: __mlir_type.index
    var file_name: __mlir_type.`!kgen.string`
    line, col, file_name = __mlir_op.`kgen.source_loc`[
        _properties = __mlir_attr.`{inlineCount = 0 : i64}`,
        _type = (
            __mlir_type.index,
            __mlir_type.index,
            __mlir_type.`!kgen.string`,
        ),
    ]()

    return _SourceLocInfo(line, col, file_name)


@always_inline("nodebug")
fn __call_loc() -> _SourceLocInfo:
    """Returns the location where the enclosing function is called.

    This should only be used in `@always_inline` and `@always_inline("nodebug")`
    functions. When the enclosing function is `@always_inline`, the call
    location will not be correct if inside a `@always_inline("nodebug")`
    function. This is intended behavior since `@always_inline("nodebug")` is
    meant to erase debug information, including locations.

    This currently doesn't work when this or the enclosing function is called in
    a parameter expression.

    Returns:
        The location information of where the enclosing function (i.e. the
          function whose body __call_loc() is used in) is called.
    """
    var line: __mlir_type.index
    var col: __mlir_type.index
    var file_name: __mlir_type.`!kgen.string`
    line, col, file_name = __mlir_op.`kgen.source_loc`[
        _properties = __mlir_attr.`{inlineCount = 1 : i64}`,
        _type = (
            __mlir_type.index,
            __mlir_type.index,
            __mlir_type.`!kgen.string`,
        ),
    ]()

    return _SourceLocInfo(line, col, file_name)
