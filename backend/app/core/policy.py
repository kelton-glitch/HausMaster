"""Who may do what. Pure data + one function: no DB, no HTTP.

Every feature asks the same question ("can this role do this action?") through
`can()`. To introduce a capability, add an `Action` and list it per role.
"""
from enum import StrEnum


class Role(StrEnum):
    OWNER = "owner"
    CO_MANAGER = "co_manager"


class Action(StrEnum):
    VIEW_PROPERTY = "view_property"
    EDIT_PROPERTY = "edit_property"
    DEACTIVATE_PROPERTY = "deactivate_property"
    MANAGE_ACCESS = "manage_access"
    MANAGE_UNITS = "manage_units"


POLICY: dict[Role, frozenset[Action]] = {
    Role.OWNER: frozenset(Action),
    # Co-managers: operational access only (view + day-to-day unit work).
    Role.CO_MANAGER: frozenset({Action.VIEW_PROPERTY, Action.MANAGE_UNITS}),
}


def can(role: Role, action: Action) -> bool:
    return action in POLICY[role]
