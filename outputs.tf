output "id" {
  description = "The name the label composed for this module's resources"
  value       = local.id
}

output "tags" {
  description = "The tags applied to every resource here: the label's ohi:* set and Name, merged with extra_tags"
  value       = local.tags
}

output "label_context" {
  description = "The context this module's label resolved to, for composing child labels that inherit its naming hierarchy. The leaf name is withheld: the label has a single name slot, so a child that inherited it would compose an id identical to this module's. Child labels must set their own name, and it replaces this one rather than nesting under it, so keep child names unique within the project/application hierarchy."
  value       = merge(module.label.context, { name = null })
}

# TODO(template): add an output per address a consumer needs — ARNs, names,
# endpoints, the role to attach further policies to. Give every output a
# description: terraform-docs renders them into README.md.
