import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["paramInput", "select"]
  static values = {
    path: String
  }

  async fetch() {
    const path = this.pathValue.replace(":param", this.paramInputTarget.value)
    await get(path, {query: {target_id: this.selectTarget.id}, responseKind: "turbo-stream"})
  }
}
