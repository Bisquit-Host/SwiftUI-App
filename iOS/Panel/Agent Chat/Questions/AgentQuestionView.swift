import ScrechKit

struct AgentQuestionView: View {
    let question: AgentQuestion
    @Binding var answer: AgentQuestionAnswer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !question.header.isEmpty {
                Text(question.multiSelect ? "\(question.header) · Pick any" : question.header)
                    .footnote()
                    .secondary()
            }
            
            Text(question.question)
            
            ForEach(question.options, id: \.self) {
                AgentQuestionOptionRow(
                    option: $0,
                    multiSelect: question.multiSelect,
                    answer: $answer
                )
            }
            
            TextField(
                question.options.isEmpty ? "Your answer" : "Other",
                text: $answer.other,
                axis: .vertical
            )
            .textFieldStyle(.roundedBorder)
        }
    }
}
