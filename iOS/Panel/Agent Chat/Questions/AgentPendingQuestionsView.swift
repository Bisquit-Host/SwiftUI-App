import ScrechKit

struct AgentPendingQuestionsView: View {
    @Environment(AgentChatVM.self) private var vm
    
    let questions: [AgentQuestion]
    
    @State private var answers: [AgentQuestionAnswer]
    
    init(questions: [AgentQuestion]) {
        self.questions = questions
        _answers = State(initialValue: questions.map { _ in AgentQuestionAnswer() })
    }
    
    private var canSubmit: Bool {
        answers.count == questions.count && !answers.contains(where: \.isEmpty)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Agent needs your input", systemImage: "questionmark.bubble")
                .headline()
            
            ForEach(questions.indices, id: \.self) { index in
                AgentQuestionView(question: questions[index], answer: $answers[index])
            }
            
            HStack {
                AsyncButton("Skip", systemImage: "forward") {
                    await vm.skipQuestions()
                }
                .secondary()
                
                AsyncButton("Send", systemImage: "paperplane") {
                    await vm.answerQuestions(answers)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSubmit)
            }
            .disabled(vm.isResolvingApproval)
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 14))
    }
}
