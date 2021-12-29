import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["paramInput", "select"]
  static values = {
    path: String
  }

  connect() {
    if (this.paramInputTarget.value) {
      this.fetch()
    } else {
      this.selectTarget.disabled = true
    }
  }

  async fetch() {
    if (!this.paramInputTarget.value) return

    const path = this.pathValue.replace(":param", this.paramInputTarget.value)
    await get(path, {query: {target_id: this.selectTarget.id}, responseKind: "turbo-stream"})
    this.selectTarget.disabled = false
  }
}
